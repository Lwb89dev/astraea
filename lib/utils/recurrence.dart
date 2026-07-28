import '../models/event_model.dart';

/// A single concrete occurrence of a (possibly recurring) [Event] inside a
/// queried date range — the base event with the start/end shifted to that
/// occurrence's instant. All times stay UTC; the UI converts to local for
/// display (see `utils/formatter.dart`).
class EventOccurrence {
  final Event event;
  final DateTime startUtc;
  final DateTime endUtc;

  const EventOccurrence({
    required this.event,
    required this.startUtc,
    required this.endUtc,
  });

  bool get isRecurringInstance => event.recurrence != RecurrenceType.none;
}

/// Expands preset recurrences into concrete [EventOccurrence]s.
///
/// MVP scope: only the [RecurrenceType] presets (daily/weekly/monthly/
/// yearly). Full RRULE (BYDAY, intervals, COUNT, exception dates, ...) is a
/// phase-2 concern and intentionally not handled here.
class RecurrenceExpander {
  RecurrenceExpander._();

  /// Returns every occurrence of [event] that overlaps the half-open UTC
  /// window `[rangeStartUtc, rangeEndUtc)`, in chronological order.
  ///
  /// For non-recurring events this is at most the single event itself.
  /// Recurrence is bounded by [Event.recurrenceEnd] (when set) and always
  /// by [rangeEndUtc], so an open-ended recurrence can't loop forever.
  static List<EventOccurrence> expand(
    Event event, {
    required DateTime rangeStartUtc,
    required DateTime rangeEndUtc,
  }) {
    assert(rangeStartUtc.isUtc && rangeEndUtc.isUtc);
    if (event.deleted) return const [];

    final duration = event.duration;
    final occurrences = <EventOccurrence>[];

    void addIfOverlaps(DateTime startUtc) {
      final endUtc = startUtc.add(duration);
      // A genuine (positive-width) interval overlaps the half-open query
      // window [rangeStartUtc, rangeEndUtc) with the standard test below.
      // A zero-duration occurrence — a point in time, not an interval; the
      // Astraea/Kairos integration mirrors a task's due instant this way,
      // startTimeUtc == endTimeUtc — needs point-in-range containment
      // instead: a zero-width "interval" satisfies neither half of the
      // interval test when it lands exactly on a boundary (e.g. local
      // midnight), which would make it belong to *no* day at all.
      final overlaps = duration == Duration.zero
          ? !startUtc.isBefore(rangeStartUtc) && startUtc.isBefore(rangeEndUtc)
          : endUtc.isAfter(rangeStartUtc) && startUtc.isBefore(rangeEndUtc);
      if (overlaps) {
        occurrences.add(
          EventOccurrence(event: event, startUtc: startUtc, endUtc: endUtc),
        );
      }
    }

    if (event.recurrence == RecurrenceType.none) {
      addIfOverlaps(event.startTimeUtc);
      return occurrences;
    }

    // Upper bound for the walk: the earlier of the recurrence end and the
    // query window end.
    final hardEnd =
        event.recurrenceEnd != null &&
            event.recurrenceEnd!.isBefore(rangeEndUtc)
        ? event.recurrenceEnd!
        : rangeEndUtc;

    var occurrenceIndex = _firstUsefulIndex(
      event.startTimeUtc,
      event.recurrence,
      rangeStartUtc.subtract(duration.isNegative ? Duration.zero : duration),
    );
    var current = _occurrenceAt(
      event.startTimeUtc,
      event.recurrence,
      occurrenceIndex,
    );
    // Safety cap so a pathological range can't spin unboundedly.
    var guard = 0;
    const maxOccurrences = 3660; // ~10 years of daily, plenty for a view.
    while (!current.isAfter(hardEnd) && guard < maxOccurrences) {
      addIfOverlaps(current);
      occurrenceIndex++;
      current = _occurrenceAt(
        event.startTimeUtc,
        event.recurrence,
        occurrenceIndex,
      );
      guard++;
    }
    return occurrences;
  }

  /// Convenience: expand a whole list of events over the same window and
  /// return all occurrences sorted by start.
  static List<EventOccurrence> expandAll(
    Iterable<Event> events, {
    required DateTime rangeStartUtc,
    required DateTime rangeEndUtc,
  }) {
    final all = <EventOccurrence>[];
    for (final event in events) {
      all.addAll(
        expand(event, rangeStartUtc: rangeStartUtc, rangeEndUtc: rangeEndUtc),
      );
    }
    all.sort((a, b) => a.startUtc.compareTo(b.startUtc));
    return all;
  }

  /// Returns a conservative index near [target] so an old open-ended series
  /// doesn't walk thousands of irrelevant occurrences before reaching the
  /// requested view. One period of slack is intentional for long events that
  /// may overlap the start of the window.
  static int _firstUsefulIndex(
    DateTime anchor,
    RecurrenceType type,
    DateTime target,
  ) {
    if (!target.isAfter(anchor)) return 0;
    return switch (type) {
      RecurrenceType.daily => (target.difference(anchor).inDays - 1).clamp(
        0,
        1 << 30,
      ),
      RecurrenceType.weekly =>
        (target.difference(anchor).inDays ~/ 7 - 1).clamp(0, 1 << 30),
      RecurrenceType.monthly =>
        ((target.year - anchor.year) * 12 + target.month - anchor.month - 1)
            .clamp(0, 1 << 30),
      RecurrenceType.yearly => (target.year - anchor.year - 1).clamp(
        0,
        1 << 30,
      ),
      RecurrenceType.none => 0,
    };
  }

  /// Calculates every occurrence from the original anchor. In particular,
  /// Jan 31 monthly becomes Feb 28/29 and then Mar 31; advancing from the
  /// previous normalized DateTime would drift permanently to March 3.
  static DateTime _occurrenceAt(
    DateTime anchor,
    RecurrenceType type,
    int index,
  ) {
    switch (type) {
      case RecurrenceType.daily:
        return anchor.add(Duration(days: index));
      case RecurrenceType.weekly:
        return anchor.add(Duration(days: index * 7));
      case RecurrenceType.monthly:
        final absoluteMonth = anchor.year * 12 + anchor.month - 1 + index;
        final year = absoluteMonth ~/ 12;
        final month = absoluteMonth % 12 + 1;
        return DateTime.utc(
          year,
          month,
          anchor.day.clamp(1, _daysInMonth(year, month)),
          anchor.hour,
          anchor.minute,
          anchor.second,
          anchor.millisecond,
          anchor.microsecond,
        );
      case RecurrenceType.yearly:
        final year = anchor.year + index;
        return DateTime.utc(
          year,
          anchor.month,
          anchor.day.clamp(1, _daysInMonth(year, anchor.month)),
          anchor.hour,
          anchor.minute,
          anchor.second,
          anchor.millisecond,
          anchor.microsecond,
        );
      case RecurrenceType.none:
        return anchor;
    }
  }

  static int _daysInMonth(int year, int month) =>
      DateTime.utc(year, month + 1, 0).day;
}
