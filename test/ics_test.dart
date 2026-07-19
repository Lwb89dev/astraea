import 'package:astraea/models/event_model.dart';
import 'package:astraea/models/reminder_model.dart';
import 'package:astraea/utils/ics.dart';
import 'package:flutter_test/flutter_test.dart';

Event _event({
  String id = 'evt-1',
  String title = 'Standup',
  RecurrenceType recurrence = RecurrenceType.none,
  DateTime? recurrenceEnd,
  List<Reminder> reminders = const [Reminder(minutesBefore: 15)],
  bool isAllDay = false,
  String? location,
}) {
  final start = DateTime.utc(2026, 7, 15, 13, 0);
  return Event(
    id: id,
    title: title,
    description: 'Daily; sync, with\nnewline',
    startTimeUtc: start,
    endTimeUtc: start.add(const Duration(hours: 1)),
    timezone: 'Europe/Rome',
    isAllDay: isAllDay,
    recurrence: recurrence,
    recurrenceEnd: recurrenceEnd,
    reminders: reminders,
    location: location,
    createdAt: DateTime.utc(2026, 7, 1),
    updatedAt: DateTime.utc(2026, 7, 1),
  );
}

void main() {
  group('IcsCodec.encode', () {
    test('produces a VCALENDAR wrapping one VEVENT', () {
      final ics = IcsCodec.encode([_event()]);
      expect(ics, contains('BEGIN:VCALENDAR'));
      expect(ics, contains('END:VCALENDAR'));
      expect(ics, contains('BEGIN:VEVENT'));
      expect(ics, contains('UID:evt-1@astraea'));
      expect(ics, contains('DTSTART:20260715T130000Z'));
      expect(ics, contains('DTEND:20260715T140000Z'));
      expect(ics, contains('SUMMARY:Standup'));
      expect(ics, contains('X-ASTRAEA-TZ:Europe/Rome'));
    });

    test('escapes text per RFC 5545 and emits a VALARM per reminder', () {
      final ics = IcsCodec.encode([_event()]);
      expect(ics, contains(r'DESCRIPTION:Daily\; sync\, with\nnewline'));
      expect(ics, contains('BEGIN:VALARM'));
      expect(ics, contains('TRIGGER:-PT15M'));
    });

    test('writes an RRULE only for recurring events', () {
      expect(IcsCodec.encode([_event()]), isNot(contains('RRULE')));
      final weekly = IcsCodec.encode([
        _event(recurrence: RecurrenceType.weekly),
      ]);
      expect(weekly, contains('RRULE:FREQ=WEEKLY'));
      final bounded = IcsCodec.encode([
        _event(
          recurrence: RecurrenceType.daily,
          recurrenceEnd: DateTime.utc(2026, 12, 31, 23, 59, 59),
        ),
      ]);
      expect(bounded, contains('RRULE:FREQ=DAILY;UNTIL=20261231T235959Z'));
    });
  });

  group('IcsCodec round trip', () {
    test('preserves the id, times, timezone, recurrence and reminders', () {
      final original = _event(
        recurrence: RecurrenceType.weekly,
        recurrenceEnd: DateTime.utc(2026, 12, 31, 23, 59, 59),
        location: 'Office',
      );
      final restored = IcsCodec.decode(
        IcsCodec.encode([original]),
        defaultTimezone: 'UTC',
      ).single;

      expect(
        restored.id,
        'evt-1',
      ); // Astraea UIDs are reused, so re-import updates in place.
      expect(restored.title, 'Standup');
      expect(restored.description, 'Daily; sync, with\nnewline');
      expect(restored.startTimeUtc, original.startTimeUtc);
      expect(restored.endTimeUtc, original.endTimeUtc);
      expect(restored.timezone, 'Europe/Rome');
      expect(restored.recurrence, RecurrenceType.weekly);
      expect(restored.recurrenceEnd, original.recurrenceEnd);
      expect(restored.reminders.single.minutesBefore, 15);
      expect(restored.location, 'Office');
      expect(restored.synced, isFalse);
    });

    test('round-trips an all-day event', () {
      final restored = IcsCodec.decode(
        IcsCodec.encode([_event(isAllDay: true)]),
        defaultTimezone: 'UTC',
      ).single;
      expect(restored.isAllDay, isTrue);
      expect(restored.startTimeUtc, DateTime.utc(2026, 7, 15));
    });
  });

  group('IcsCodec.decode', () {
    test('rejects a non-iCalendar document', () {
      expect(
        () => IcsCodec.decode('just some text', defaultTimezone: 'UTC'),
        throwsA(isA<FormatException>()),
      );
    });

    test('imports pre-rename Epochs UIDs and custom properties', () {
      const legacy = '''
BEGIN:VCALENDAR
BEGIN:VEVENT
UID:legacy-id@epochs
DTSTART:20260715T130000Z
DTEND:20260715T140000Z
SUMMARY:Legacy
X-EPOCHS-TZ:Europe/Rome
X-EPOCHS-COLOR:0xFF112233
END:VEVENT
END:VCALENDAR
''';
      final event = IcsCodec.decode(legacy, defaultTimezone: 'UTC').single;
      expect(event.id, 'legacy-id');
      expect(event.timezone, 'Europe/Rome');
      expect(event.color, '0xFF112233');
    });

    test('gives a foreign event a fresh id and the default timezone', () {
      const foreign = '''
BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
UID:something@google.com
DTSTART:20260715T130000Z
DTEND:20260715T140000Z
SUMMARY:Imported
END:VEVENT
END:VCALENDAR
''';
      final event = IcsCodec.decode(
        foreign,
        defaultTimezone: 'Europe/Rome',
      ).single;
      expect(event.id, isNot('something'));
      expect(event.id, isNotEmpty);
      expect(event.title, 'Imported');
      expect(event.timezone, 'Europe/Rome');
    });

    test('unfolds long folded lines', () {
      const folded = '''
BEGIN:VCALENDAR
BEGIN:VEVENT
DTSTART:20260715T130000Z
SUMMARY:A very long tit
 le that was folded
END:VEVENT
END:VCALENDAR
''';
      expect(
        IcsCodec.decode(folded, defaultTimezone: 'UTC').single.title,
        'A very long title that was folded',
      );
    });

    test('drops RRULEs it cannot faithfully expand rather than guessing', () {
      // INTERVAL=2 and BYDAY describe patterns RecurrenceExpander can't model;
      // importing them as a plain weekly rule would put events on wrong days.
      String withRule(String rule) =>
          '''
BEGIN:VCALENDAR
BEGIN:VEVENT
DTSTART:20260715T130000Z
SUMMARY:X
RRULE:$rule
END:VEVENT
END:VCALENDAR
''';
      expect(
        IcsCodec.decode(
          withRule('FREQ=WEEKLY;INTERVAL=2'),
          defaultTimezone: 'UTC',
        ).single.recurrence,
        RecurrenceType.none,
      );
      expect(
        IcsCodec.decode(
          withRule('FREQ=WEEKLY;BYDAY=MO,WE'),
          defaultTimezone: 'UTC',
        ).single.recurrence,
        RecurrenceType.none,
      );
      expect(
        IcsCodec.decode(
          withRule('FREQ=WEEKLY'),
          defaultTimezone: 'UTC',
        ).single.recurrence,
        RecurrenceType.weekly,
      );
    });

    test(
      'parses VALARM triggers in hours and days, ignoring post-start ones',
      () {
        String withTrigger(String trigger) =>
            '''
BEGIN:VCALENDAR
BEGIN:VEVENT
DTSTART:20260715T130000Z
SUMMARY:X
BEGIN:VALARM
TRIGGER:$trigger
END:VALARM
END:VEVENT
END:VCALENDAR
''';
        List<Reminder> remindersFor(String t) => IcsCodec.decode(
          withTrigger(t),
          defaultTimezone: 'UTC',
        ).single.reminders;

        expect(remindersFor('-PT1H').single.minutesBefore, 60);
        expect(remindersFor('-P1D').single.minutesBefore, 1440);
        expect(remindersFor('PT0S').single.minutesBefore, 0);
        expect(
          remindersFor('PT30M'),
          isEmpty,
        ); // After the start: not a reminder.
      },
    );

    test('skips a VEVENT with no DTSTART instead of failing the import', () {
      const mixed = '''
BEGIN:VCALENDAR
BEGIN:VEVENT
SUMMARY:Broken
END:VEVENT
BEGIN:VEVENT
DTSTART:20260715T130000Z
SUMMARY:Good
END:VEVENT
END:VCALENDAR
''';
      final events = IcsCodec.decode(mixed, defaultTimezone: 'UTC');
      expect(events, hasLength(1));
      expect(events.single.title, 'Good');
    });
  });
}
