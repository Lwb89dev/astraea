import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import '../models/event_model.dart';

/// Display helpers that convert the always-UTC event instants into the
/// event's (or the app's) timezone for the UI. Stored data stays UTC; only
/// presentation is localized (the app's core timezone rule).
class Formatter {
  Formatter._();

  /// Truncates a hex/npub key for display (e.g. "npub1abc…wxyz") — the
  /// fallback when an account has no kind-0 profile name.
  static String truncateKey(String key, {int head = 8, int tail = 4}) {
    if (key.length <= head + tail) return key;
    return '${key.substring(0, head)}…${key.substring(key.length - tail)}';
  }

  /// Converts a UTC [instant] into wall-clock time in [ianaTimezone],
  /// falling back to the device-local conversion if the zone name is
  /// unknown (e.g. before the timezone database is initialized).
  static DateTime toZoned(DateTime instant, String ianaTimezone) {
    try {
      final location = tz.getLocation(ianaTimezone);
      return tz.TZDateTime.from(instant, location);
    } catch (_) {
      return instant.toLocal();
    }
  }

  /// "Mon 15 Jul 2026" — a day header for list/day views.
  static String dayLabel(DateTime instant, String ianaTimezone) {
    final zoned = toZoned(instant, ianaTimezone);
    return DateFormat('EEE d MMM y').format(zoned);
  }

  /// "Mon 15 Jul 2026" for a date already expressed in device-local time.
  /// The calendar's day grouping is local, so its headers must be too —
  /// converting a local midnight to UTC first would label the previous day
  /// for any timezone east of Greenwich.
  static String dayLabelLocal(DateTime localDay) =>
      DateFormat('EEE d MMM y').format(localDay);

  /// "13:00" in device-local time — what the calendar lists show, per the
  /// app's display rule (store UTC, display local). The event's own timezone
  /// stays visible in the details/editor, where it's authoring information.
  static String timeLabelLocal(DateTime utcInstant) =>
      DateFormat.Hm().format(utcInstant.toLocal());

  /// "Mon 15 Jul 2026, 13:00" — a fuller single-line stamp for details.
  static String fullLabel(DateTime instant, String ianaTimezone) {
    final zoned = toZoned(instant, ianaTimezone);
    return DateFormat('EEE d MMM y, HH:mm').format(zoned);
  }

  /// Human label for a recurrence preset.
  static String recurrenceLabel(AppLocalizations l10n, RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return l10n.recurrenceNone;
      case RecurrenceType.daily:
        return l10n.recurrenceDaily;
      case RecurrenceType.weekly:
        return l10n.recurrenceWeekly;
      case RecurrenceType.monthly:
        return l10n.recurrenceMonthly;
      case RecurrenceType.yearly:
        return l10n.recurrenceYearly;
    }
  }

  /// Human label for a reminder offset in minutes.
  static String reminderLabel(AppLocalizations l10n, int minutesBefore) {
    if (minutesBefore == 0) return l10n.reminderAtStart;
    if (minutesBefore < 60) return l10n.reminderMinutesBefore(minutesBefore);
    if (minutesBefore % 1440 == 0) {
      return l10n.reminderDaysBefore(minutesBefore ~/ 1440);
    }
    if (minutesBefore % 60 == 0) {
      return l10n.reminderHoursBefore(minutesBefore ~/ 60);
    }
    return l10n.reminderMinutesBefore(minutesBefore);
  }
}
