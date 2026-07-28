import 'dart:convert';
import 'dart:developer' as developer;

import 'package:home_widget/home_widget.dart';

import '../models/event_model.dart';
import '../utils/recurrence.dart';

/// Feeds the Android home-screen widgets (daily / weekly / monthly agenda).
///
/// The widgets are standalone: they are drawn natively from this cached data
/// (RemoteViews + RemoteViewsFactory — see AstraeaWidgetProviders.kt), not by
/// the app. Android can therefore redraw them on its own — on a periodic tick,
/// at midnight, after a reboot — while Astraea isn't running at all. Tapping one
/// opens the app, but that is a convenience, not what makes it work.
///
/// That is also why this pushes a whole *window* of occurrences rather than
/// "today's events": the native side picks out today / this week / this month
/// at draw time, so the widget rolls over to the next day correctly without the
/// app ever being opened.
class HomeWidgetService {
  /// Fully-qualified AppWidgetProvider class names (see AndroidManifest.xml).
  static const _package = 'com.example.astraea';
  static const dayProvider = '$_package.AstraeaDayWidgetProvider';
  static const weekProvider = '$_package.AstraeaWeekWidgetProvider';
  static const monthProvider = '$_package.AstraeaMonthWidgetProvider';

  /// The key the native side reads the occurrence list from. Kept stable so
  /// widgets retain their cache across the Astraea rename.
  static const _eventsKey = 'epochs_events';

  /// Deep links the widgets fire back into the app (see
  /// [WidgetLaunchHandler]). The native side builds the same URIs.
  static const scheme = 'astraea';
  static const legacyScheme = 'epochs';
  static const newEventHost = 'new-event';
  static const eventHost = 'event';

  /// How much of the calendar is handed to the widgets. The native widgets can
  /// move independently from the app, so keep a useful window on both sides of
  /// today rather than caching only the current and following month.
  static const _windowBefore = Duration(days: 92);
  static const _windowAfter = Duration(days: 185);

  /// Publishes [events] to the widgets and asks Android to redraw them.
  ///
  /// Best-effort: failures are swallowed and logged. A widget that couldn't be
  /// refreshed must never break the app action that triggered this, and on
  /// non-Android platforms the plugin's methods are simply unimplemented.
  Future<void> updateAll(List<Event> events) async {
    developer.log(
      'HomeWidgetService.updateAll called (${events.length} events)',
      name: 'HomeWidgetService',
    );
    try {
      final now = DateTime.now();
      // Anchor the cache to today, not to the first of the month. This keeps
      // the native day widget's full backward window available even near a
      // month boundary, and still gives the month widget all of its visible
      // leading/trailing days.
      final today = DateTime(now.year, now.month, now.day);
      final from = today.subtract(_windowBefore);
      final occurrences = RecurrenceExpander.expandAll(
        events,
        rangeStartUtc: from.toUtc(),
        // Include the complete last local day in the half-open range.
        rangeEndUtc: DateTime(
          today.year,
          today.month,
          today.day + _windowAfter.inDays + 1,
        ).toUtc(),
      );

      final payload = jsonEncode([
        for (final o in occurrences)
          {
            // The id travels with each row so tapping one can deep-link
            // straight to that event's details (astraea://event?id=…).
            'i': o.event.id,
            's': o.startUtc.millisecondsSinceEpoch,
            'e': o.endUtc.millisecondsSinceEpoch,
            't': o.event.title,
            'c': o.event.color,
            'a': o.event.isAllDay,
          },
      ]);

      final saved = await HomeWidget.saveWidgetData<String>(
        _eventsKey,
        payload,
      );
      if (saved != true) {
        throw StateError('HomeWidget data could not be saved.');
      }
      await HomeWidget.updateWidget(qualifiedAndroidName: dayProvider);
      await HomeWidget.updateWidget(qualifiedAndroidName: weekProvider);
      await HomeWidget.updateWidget(qualifiedAndroidName: monthProvider);
    } catch (e) {
      developer.log(
        'Could not update home widgets: $e',
        name: 'HomeWidgetService',
      );
    }
  }
}
