import 'dart:convert';

import 'package:astraea/services/kairos_local_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodes a compact Kairos task and adds a due notification', () {
    final event = KairosLocalService.decodeTask(
      jsonEncode({
        'protocol': 1,
        'taskId': 'task-1',
        'title': 'Pay invoice',
        'dueAt': '2030-01-02T09:00:00Z',
      }),
    );

    expect(event.id, 'task-1');
    expect(event.title, 'Pay invoice');
    expect(event.startTimeUtc, DateTime.utc(2030, 1, 2, 9));
    expect(event.endTimeUtc, event.startTimeUtc);
    expect(event.reminders.single.minutesBefore, 0);
    expect(event.synced, isTrue);
  });

  test('decodes Kairos envelope and preserves its operation/notification', () {
    final message = KairosLocalService.decode(
      jsonEncode({
        'protocol': 'dev.echoes.astraea.local',
        'version': 1,
        'source': 'kairos',
        'operation': 'upsert',
        'taskId': 'task-2',
        'event': {
          'id': 'task-2',
          'title': 'Prepare release',
          'startTimeUtc': '2030-01-02T09:00:00Z',
          'endTimeUtc': '2030-01-02T09:00:00.001Z',
          'reminders': [
            {'minutesBefore': 15},
          ],
          'updatedAt': 1893574800000,
        },
        'notification': {
          'show': true,
          'dedupeKey': 'kairos:task-2:1893574800000',
        },
      }),
    );

    expect(message.operation, 'upsert');
    expect(message.event.id, 'task-2');
    expect(message.event.reminders.single.minutesBefore, 15);
    expect(message.showNotification, isTrue);
    expect(message.dedupeKey, 'kairos:task-2:1893574800000');
  });

  test('turns a delete envelope into a tombstone without a notification', () {
    final message = KairosLocalService.decode(
      jsonEncode({
        'protocol': 'dev.echoes.astraea.local',
        'version': 1,
        'source': 'kairos',
        'operation': 'delete',
        'taskId': 'task-3',
        'event': {
          'id': 'task-3',
          'title': 'Deleted task',
          'dueAt': '2030-01-02T09:00:00Z',
          'updatedAt': 1893574800000,
        },
        'notification': {'show': false},
      }),
    );

    expect(message.operation, 'delete');
    expect(message.event.deleted, isTrue);
    expect(message.showNotification, isFalse);
  });
}
