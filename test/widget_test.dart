import 'package:astraea/models/event_model.dart';
import 'package:astraea/models/reminder_model.dart';
import 'package:astraea/utils/recurrence.dart';
import 'package:astraea/utils/event_timestamp.dart';
import 'package:flutter_test/flutter_test.dart';

// Pure-logic tests for the calendar core (no Flutter/plugin dependencies):
// event JSON round-tripping and recurrence-preset expansion. Widget-level
// smoke tests are deferred until the services no longer need native plugins
// (Hive/secure storage/timezone) to boot.

Event _sampleEvent({
  RecurrenceType recurrence = RecurrenceType.none,
  DateTime? recurrenceEnd,
  String? syncOwnerPubkey,
}) {
  final start = DateTime.utc(2026, 7, 15, 13, 0);
  return Event(
    id: 'evt-1',
    title: 'Standup',
    description: 'Daily sync',
    startTimeUtc: start,
    endTimeUtc: start.add(const Duration(hours: 1)),
    timezone: 'Europe/Rome',
    recurrence: recurrence,
    recurrenceEnd: recurrenceEnd,
    reminders: const [Reminder(minutesBefore: 15)],
    syncOwnerPubkey: syncOwnerPubkey,
    createdAt: DateTime.utc(2026, 7, 1),
    updatedAt: DateTime.utc(2026, 7, 1),
  );
}

void main() {
  group('Nostr event timestamps', () {
    test('a rapid follow-up mutation advances to the next second', () {
      final previous = DateTime.utc(2026, 7, 19, 10, 0, 0, 900);
      final result = nextEventTimestamp(
        previous,
        now: DateTime.utc(2026, 7, 19, 10, 0, 0, 950),
      );

      expect(result, DateTime.utc(2026, 7, 19, 10, 0, 1));
    });

    test('a later wall clock instant is preserved', () {
      final now = DateTime.utc(2026, 7, 19, 10, 0, 3, 250);
      expect(nextEventTimestamp(DateTime.utc(2026, 7, 19, 10), now: now), now);
    });
  });

  group('Event serialization', () {
    test('round-trips through JSON preserving UTC and fields', () {
      final event = _sampleEvent(
        recurrence: RecurrenceType.weekly,
        syncOwnerPubkey: 'owner-pubkey',
      );
      final restored = Event.fromJson(event.toJson());

      expect(restored.id, event.id);
      expect(restored.title, event.title);
      expect(restored.startTimeUtc, event.startTimeUtc);
      expect(restored.startTimeUtc.isUtc, isTrue);
      expect(restored.timezone, 'Europe/Rome');
      expect(restored.recurrence, RecurrenceType.weekly);
      expect(restored.reminders.single.minutesBefore, 15);
      expect(restored.dTag, 'epochs:evt-1');
      expect(restored.syncOwnerPubkey, 'owner-pubkey');
    });

    test('serializes a non-recurring event with a null recurrence', () {
      final json = _sampleEvent().toJson();
      expect(json['recurrence'], isNull);
    });

    test('accepts Hive-style dynamically keyed reminder maps', () {
      final event = _sampleEvent();
      final stored = Map<dynamic, dynamic>.from(event.toJson());
      stored['reminders'] = <dynamic>[
        <dynamic, dynamic>{'minutesBefore': 15},
      ];

      final restored = Event.fromJson(Map<String, dynamic>.from(stored));

      expect(restored.reminders, hasLength(1));
      expect(restored.reminders.single.minutesBefore, 15);
    });
  });

  group('RecurrenceExpander', () {
    test('a non-recurring event yields at most one occurrence in range', () {
      final event = _sampleEvent();
      final occ = RecurrenceExpander.expand(
        event,
        rangeStartUtc: DateTime.utc(2026, 7, 1),
        rangeEndUtc: DateTime.utc(2026, 8, 1),
      );
      expect(occ, hasLength(1));
      expect(occ.single.startUtc, event.startTimeUtc);
    });

    test(
      'daily recurrence produces one occurrence per day within the window',
      () {
        final event = _sampleEvent(recurrence: RecurrenceType.daily);
        final occ = RecurrenceExpander.expand(
          event,
          rangeStartUtc: DateTime.utc(2026, 7, 15),
          rangeEndUtc: DateTime.utc(2026, 7, 22), // 7-day half-open window
        );
        expect(occ, hasLength(7));
        // Occurrences keep the original duration.
        expect(
          occ.first.endUtc.difference(occ.first.startUtc),
          const Duration(hours: 1),
        );
      },
    );

    test('recurrenceEnd bounds the expansion', () {
      final event = _sampleEvent(
        recurrence: RecurrenceType.daily,
        recurrenceEnd: DateTime.utc(2026, 7, 17, 13, 0),
      );
      final occ = RecurrenceExpander.expand(
        event,
        rangeStartUtc: DateTime.utc(2026, 7, 1),
        rangeEndUtc: DateTime.utc(2026, 8, 1),
      );
      // 15th, 16th, 17th only.
      expect(occ, hasLength(3));
      expect(occ.last.startUtc, DateTime.utc(2026, 7, 17, 13, 0));
    });

    test('a deleted event expands to nothing', () {
      final event = _sampleEvent(
        recurrence: RecurrenceType.daily,
      ).copyWith(deleted: true);
      final occ = RecurrenceExpander.expand(
        event,
        rangeStartUtc: DateTime.utc(2026, 7, 1),
        rangeEndUtc: DateTime.utc(2026, 8, 1),
      );
      expect(occ, isEmpty);
    });

    test('an old daily series jumps directly to the requested window', () {
      final start = DateTime.utc(2000, 1, 1, 9);
      final event = Event(
        id: 'old-daily',
        title: 'Daily',
        startTimeUtc: start,
        endTimeUtc: start.add(const Duration(hours: 1)),
        timezone: 'UTC',
        recurrence: RecurrenceType.daily,
        createdAt: start,
        updatedAt: start,
      );
      final occ = RecurrenceExpander.expand(
        event,
        rangeStartUtc: DateTime.utc(2026, 7, 15),
        rangeEndUtc: DateTime.utc(2026, 7, 18),
      );
      expect(occ.map((o) => o.startUtc.day), [15, 16, 17]);
    });

    test('monthly recurrence remains anchored after a short month', () {
      final start = DateTime.utc(2026, 1, 31, 9);
      final event = Event(
        id: 'month-end',
        title: 'Month end',
        startTimeUtc: start,
        endTimeUtc: start.add(const Duration(hours: 1)),
        timezone: 'UTC',
        recurrence: RecurrenceType.monthly,
        createdAt: start,
        updatedAt: start,
      );
      final occ = RecurrenceExpander.expand(
        event,
        rangeStartUtc: DateTime.utc(2026, 1, 1),
        rangeEndUtc: DateTime.utc(2026, 4, 1),
      );
      expect(occ.map((o) => (o.startUtc.month, o.startUtc.day)), [
        (1, 31),
        (2, 28),
        (3, 31),
      ]);
    });
  });
}
