// Cross-implementation wire-compat tests: asserts the SAME fixtures the Rust
// service asserts (native/service/tests/wire_compat.rs) against this app's
// Event codec. docs/nostr-sync.md is the normative contract; a payload the
// two implementations read differently is a contract bug.
import 'dart:convert';
import 'dart:io';

import 'package:astraea/models/event_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final doc =
      jsonDecode(File('test/fixtures/wire_payloads.json').readAsStringSync())
          as Map<String, dynamic>;
  final cases = (doc['parseCases'] as List).cast<Map<String, dynamic>>();

  group('shared wire payload fixtures', () {
    for (final c in cases) {
      test(c['name'] as String, () {
        final payload = c['payload'] as Map<String, dynamic>;
        final expect_ = c['expect'] as Map<String, dynamic>;
        final event = Event.fromJson(payload);

        expect(event.id, expect_['id']);
        expect(event.title, expect_['title']);
        expect(
          event.startTimeUtc.millisecondsSinceEpoch,
          expect_['startMs'],
          reason: 'start',
        );
        expect(
          event.endTimeUtc.millisecondsSinceEpoch,
          expect_['endMs'],
          reason: 'end',
        );
        expect(event.timezone, expect_['timezone']);
        expect(event.isAllDay, expect_['allDay']);
        expect(event.recurrence.jsonValue, expect_['recurrence'],
            reason: 'unknown recurrence values must degrade to none');
        expect(
          event.recurrenceEnd?.millisecondsSinceEpoch,
          expect_['recurrenceEndMs'],
          reason: 'recurrenceEnd',
        );
        expect(
          event.reminders.map((r) => r.minutesBefore).toList(),
          (expect_['reminderMinutes'] as List).cast<int>(),
          reason: 'reminders',
        );
        expect(event.location, expect_['location']);
        expect(event.deleted, expect_['deleted']);
        expect(
          event.createdAt.millisecondsSinceEpoch,
          expect_['createdAtMs'],
          reason: 'createdAt must tolerate both ms ints and ISO strings',
        );
        expect(
          event.updatedAt.millisecondsSinceEpoch,
          expect_['updatedAtMs'],
          reason: 'updatedAt must tolerate both ms ints and ISO strings',
        );
      });
    }
  });

  test('re-serializing a parsed payload keeps the contract fields', () {
    // The produce direction: what this app writes back must stay readable
    // with identical values (unknown fields are allowed to be dropped).
    for (final c in cases) {
      final original = Event.fromJson(c['payload'] as Map<String, dynamic>);
      final reparsed = Event.fromJson(original.toJson());
      expect(reparsed.id, original.id);
      expect(reparsed.startTimeUtc, original.startTimeUtc);
      expect(reparsed.endTimeUtc, original.endTimeUtc);
      expect(reparsed.recurrence, original.recurrence);
      expect(reparsed.updatedAt, original.updatedAt);
      expect(reparsed.deleted, original.deleted);
    }
  });
}
