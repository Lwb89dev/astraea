import 'dart:developer' as developer;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/event_model.dart';
import '../utils/constants.dart';
import '../utils/recurrence.dart';
import 'local_storage_service.dart';

/// Local reminder notifications, handed to the OS at event create/edit time
/// and delivered by it — no polling, no android_alarm_manager.
///
/// Each [Reminder] on an event becomes one `zonedSchedule()` per upcoming
/// occurrence: the exact instant is the occurrence's start minus
/// `minutesBefore`, converted to a [tz.TZDateTime] so the OS fires it at the
/// right wall-clock moment across DST changes.
///
/// Recurring events are not scheduled with `matchDateTimeComponents` (which
/// only covers daily/weekly and repeats forever): occurrences are expanded
/// explicitly instead, which is the only way to honour [Event.recurrenceEnd]
/// and the monthly/yearly presets. That means an open-ended recurrence is only
/// scheduled [_schedulingWindow] ahead, so [rescheduleAll] is re-run on every
/// app open to roll the window forward.
///
/// Android drops all alarms on reboot; the plugin's own
/// `ScheduledNotificationBootReceiver` (declared in AndroidManifest.xml)
/// restores them, so nothing here needs a BOOT_COMPLETED path of its own.
class NotificationService {
  NotificationService({required LocalStorageService localStorageService})
    : _localStorage = localStorageService;

  final LocalStorageService _localStorage;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// How far ahead recurring occurrences are scheduled. Android caps how many
  /// alarms an app may hold, so this trades "reminders keep firing forever
  /// without opening the app" for staying well inside that budget.
  static const _schedulingWindow = Duration(days: 90);

  /// Cap per event, so one busy daily recurrence can't consume the whole
  /// alarm budget on its own.
  static const _maxOccurrencesPerEvent = 16;

  bool _initialized = false;

  /// One-time init: initializes the plugin, creates the Android channel and
  /// asks for the permissions scheduling needs. Called from `main()` before the
  /// first frame.
  Future<void> init() async {
    developer.log(
      'NotificationService.init called',
      name: 'NotificationService',
    );
    if (_initialized) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings);

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          AppConstants.reminderChannelId,
          AppConstants.reminderChannelName,
          description: AppConstants.reminderChannelDescription,
          importance: Importance.high,
        ),
      );
      // POST_NOTIFICATIONS (Android 13+) and exact alarms (Android 12+). Both
      // are best-effort: a refusal must not break startup, it just means
      // reminders won't show / will be inexact until granted.
      await android.requestNotificationsPermission();
      await android.requestExactAlarmsPermission();
    }
    _initialized = true;
  }

  /// (Re)schedules every reminder for [event]. Idempotent: any notifications
  /// previously scheduled for this event are cancelled first, so editing an
  /// event never leaves a stale reminder behind.
  ///
  /// No-op when reminders are switched off in Settings, when the event is a
  /// deletion tombstone, or when it has no reminders.
  Future<void> scheduleForEvent(Event event) async {
    developer.log(
      'NotificationService.scheduleForEvent called: ${event.id}',
      name: 'NotificationService',
    );
    await cancelForEvent(event.id);
    if (event.deleted || event.reminders.isEmpty) return;
    if (!await _remindersEnabled()) return;

    final now = DateTime.now().toUtc();
    final occurrences = RecurrenceExpander.expand(
      event,
      rangeStartUtc: now,
      rangeEndUtc: now.add(_schedulingWindow),
    ).take(_maxOccurrencesPerEvent);

    // Every (occurrence, reminder) pair whose fire instant is still ahead. The
    // reminder offset travels with each instant: the body ("starts in 15 min")
    // must describe *this occurrence*, not the series' first start.
    final pending = <({DateTime fireAt, int minutesBefore})>[];
    for (final occurrence in occurrences) {
      for (final reminder in event.reminders) {
        final fireAt = occurrence.startUtc.subtract(
          Duration(minutes: reminder.minutesBefore),
        );
        if (fireAt.isAfter(now)) {
          pending.add((fireAt: fireAt, minutesBefore: reminder.minutesBefore));
        }
      }
    }
    if (pending.isEmpty) return;

    final ids = await _localStorage.allocateNotificationIds(pending.length);
    final scheduled = <int>[];
    for (var i = 0; i < pending.length; i++) {
      try {
        await _plugin.zonedSchedule(
          ids[i],
          event.title.isEmpty ? 'Event' : event.title,
          _bodyFor(event.isAllDay, pending[i].minutesBefore),
          tz.TZDateTime.from(pending[i].fireAt, tz.local),
          _details(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: event.id,
        );
        scheduled.add(ids[i]);
      } catch (e) {
        // A single failed alarm (e.g. exact-alarm permission denied) must not
        // abort the rest — record only what actually got through, so cancel
        // stays accurate.
        developer.log(
          'Could not schedule reminder for ${event.id}: $e',
          name: 'NotificationService',
        );
      }
    }
    await _localStorage.saveNotificationIds(event.id, scheduled);
  }

  /// Cancels every notification scheduled for [eventId] (on delete, and before
  /// re-scheduling on edit).
  Future<void> cancelForEvent(String eventId) async {
    final ids = await _localStorage.loadNotificationIds(eventId);
    if (ids.isEmpty) return;
    developer.log(
      'NotificationService.cancelForEvent: ${ids.length} for $eventId',
      name: 'NotificationService',
    );
    for (final id in ids) {
      await _plugin.cancel(id);
    }
    await _localStorage.clearNotificationIds(eventId);
  }

  /// Re-schedules reminders for all [events]: called on app open (to roll the
  /// [_schedulingWindow] forward) and after the reminders toggle is turned back
  /// on.
  Future<void> rescheduleAll(List<Event> events) async {
    developer.log(
      'NotificationService.rescheduleAll: ${events.length} event(s)',
      name: 'NotificationService',
    );
    for (final event in events) {
      await scheduleForEvent(event);
    }
  }

  /// Cancels everything Astraea has scheduled — used when the reminders toggle
  /// is switched off.
  Future<void> cancelAll() async {
    developer.log(
      'NotificationService.cancelAll called',
      name: 'NotificationService',
    );
    // Only cancel ids we know are ours rather than `_plugin.cancelAll()`, which
    // would also drop notifications scheduled by anything else in the app.
    for (final id in await _localStorage.loadAllNotificationIds()) {
      await _plugin.cancel(id);
    }
    await _localStorage.clearAllNotificationIds();
  }

  Future<bool> _remindersEnabled() async {
    final settings = await _localStorage.loadSettings();
    return settings.notificationsEnabled;
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.reminderChannelId,
        AppConstants.reminderChannelName,
        channelDescription: AppConstants.reminderChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.event,
        visibility: NotificationVisibility.private,
      ),
    );
  }

  /// "Starts in 15 min" / "Starting now", from the reminder's own offset.
  String _bodyFor(bool isAllDay, int minutesBefore) {
    if (isAllDay) return 'All day';
    if (minutesBefore <= 0) return 'Starting now';
    if (minutesBefore < 60) return 'Starts in $minutesBefore min';
    if (minutesBefore % 1440 == 0) {
      final days = minutesBefore ~/ 1440;
      return days == 1 ? 'Starts tomorrow' : 'Starts in $days days';
    }
    if (minutesBefore % 60 == 0) {
      final hours = minutesBefore ~/ 60;
      return hours == 1 ? 'Starts in 1 hour' : 'Starts in $hours hours';
    }
    return 'Starts in $minutesBefore min';
  }
}
