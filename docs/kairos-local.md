# Kairos → Astraea local bridge

Nostr remains the durable cross-device transport. When the user enables
“visualizza in Astraea” in Kairos, Kairos also sends the same calendar mirror
to the local Astraea installation.

The message is a versioned JSON envelope:

```json
{
  "protocol": "dev.echoes.astraea.local",
  "version": 1,
  "source": "kairos",
  "operation": "upsert",
  "taskId": "task-uuid",
  "event": {
    "id": "task-uuid",
    "title": "Pay invoice",
    "dueAt": "2030-01-02T09:00:00.000Z",
    "timezone": "Europe/Rome",
    "reminders": [{"minutesBefore": 0}],
    "updatedAt": 1893574800000
  },
  "notification": {"show": true}
}
```

On Android, Kairos sends the JSON as an explicit intent:

- action: `dev.echoes.astraea.action.LOCAL_SYNC`
- extra: `dev.echoes.astraea.extra.PAYLOAD`
- MIME type: `application/json`

Astraea queues cold-start intents until Flutter is ready, validates the
payload, merges by the shared task id and revision, refreshes the calendar and
widgets, and schedules the notification. If no reminder is supplied, an
upsert with `notification.show: true` schedules one at the due instant.

`operation: delete` writes a local tombstone and cancels the task's reminder.
Older or repeated messages are harmless. Local messages are marked as already
owned by Kairos' Nostr mirror, so Astraea does not publish a duplicate relay
event.

On Linux, Kairos sends the same envelope over the per-user Unix socket:

```text
$XDG_RUNTIME_DIR/astraea-kairos.sock
```

One JSON envelope is sent per line. The task id must match the id used by
Kairos' Nostr calendar mirror; this is what makes local delivery and later
relay delivery converge on one event. The existing `astraea://kairos/task`
deep link remains accepted for other desktop integrations.
