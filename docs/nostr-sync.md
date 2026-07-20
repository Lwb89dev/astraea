# Nostr sync — wire contract

This document is **normative**. The Dart implementation
(`lib/services/nostr_service.dart`, `lib/services/calendar_sync_service.dart`)
and the Rust implementation (`native/service/src/sync/`) must both conform;
divergence is a bug in whichever side broke the contract.
Shared JSON fixtures live in `test/fixtures/` and are exercised by both test
suites.

## Identity and encryption

- Events are **self-encrypted**: NIP-44 v2 with the conversation key derived
  from the user's own keypair (sender = recipient = the account key).
- The Dart side implements NIP-44 in `lib/utils/nip44.dart` and validates the
  official spec vectors (`test/nip44_test.dart`). The Rust side uses the
  audited `nostr` crate NIP-44 implementation and validates the same vectors.

## The calendar event (kind 30078)

| Field | Value |
| --- | --- |
| `kind` | `30078` (NIP-78 application-specific data, parameterized replaceable) |
| `tags` | exactly one `["d", "epochs:<event-uuid>"]` |
| `content` | NIP-44 v2 ciphertext of the payload JSON below |
| `created_at` | the event's `updatedAt`, in Unix seconds |

The `d`-tag prefix is the **legacy** `epochs:` (pre-rename wire
compatibility). Relays cannot filter by prefix, so pulls request all of the
author's kind-30078 events and filter client-side.

`created_at = updatedAt` is load-bearing: relays keep only the newest event
per `(pubkey, kind, d)`, so replaceable-event ordering must match the
last-write-wins merge key. Writers must guarantee strictly increasing
`updatedAt` per event id (second resolution — bump by 1 s if needed, see
`lib/utils/event_timestamp.dart`).

## Payload JSON (the plaintext inside `content`)

Produced by Dart `Event.toJson()`:

```json
{
  "id": "uuid-v4",
  "title": "string",
  "description": "string",
  "startTimeUtc": "2026-07-19T09:00:00.000Z",
  "endTimeUtc": "2026-07-19T10:00:00.000Z",
  "timezone": "Europe/Rome",
  "isAllDay": false,
  "recurrence": null,
  "recurrenceEnd": null,
  "reminders": [{"minutesBefore": 10}],
  "color": "0xFF2196F3",
  "location": null,
  "synced": true,
  "nostrEventId": "hex or null",
  "syncOwnerPubkey": "hex or null",
  "deleted": false,
  "createdAt": 1752915600000,
  "updatedAt": 1752915600000
}
```

Rules every implementation must follow:

- `startTimeUtc`/`endTimeUtc`/`recurrenceEnd`: ISO-8601 strings, UTC.
- `createdAt`/`updatedAt`: **milliseconds** since epoch as integers
  (readers must also tolerate ISO strings — historical).
- `recurrence`: `null` | `"daily"` | `"weekly"` | `"monthly"` | `"yearly"`.
  Unknown values degrade to `null` (non-recurring), never to an error.
- `color`: legacy Flutter ARGB literal string `0xAARRGGBB`.
- `deleted: true` payloads are tombstones; readers keep them (LWW applies)
  and hide them from views.
- **Unknown fields are ignored, and writers are not required to preserve
  them** (a re-publish by an older client may drop them). New fields must
  therefore be non-critical or degrade safely (see `calendarId` below).
- Readers skip (never fail on) payloads that don't decrypt or parse.

### Linux-side extension fields (v1, optional)

The Rust service adds, and understands, these optional fields; Android
currently ignores/drops them (accepted degradation, ADR-005):

- `calendarId` (string): local calendar membership. Missing → default
  calendar.
- `url` (string): event URL.

## Merge

Pull all kind-30078 events with the `epochs:` d-prefix, verify NIP-01 id +
Schnorr signature and `pubkey == account`, decrypt, then merge per event
`id` with **last-write-wins on `updatedAt`** (strictly-after wins; ties keep
local). Then push every local event with pending changes.

## Deletion

Two redundant mechanisms, both required:

1. Re-publish the payload as a tombstone (`deleted: true`) under the same
   `d` tag — replaceable, so every relay overwrites the live version and
   other devices merge the tombstone.
2. Publish NIP-09 (kind 5) with an `e` tag for the **previous concrete
   event id only** — never the replaceable coordinate (`a` tag), or the
   tombstone itself would be deleted and other devices could resurrect the
   event.

Local hard-delete of a tombstone is only allowed once it is synced
(`deleted_synced`), and even then implementations may keep it.

## Publication semantics

- An event counts as synced only when **every configured relay** accepted
  it (OK with `true`). Partial acceptance leaves it pending; republish is
  idempotent (same id for same fields).
- Relay URLs must be `wss://`, no userinfo, no fragment, ≤ 2048 chars.
- Bounds while fetching: ignore events with `content` > 90 000 chars; stop
  collecting past 5 000 events per REQ.

## Rust service specifics (superset, local only)

The service's SQLite schema tracks a richer `sync_state` machine
(`local_only`, `pending_signature`, `pending_publish`, `publishing`,
`synced`, `conflict`, `failed`, `deleted_pending`, `deleted_synced`) and a
persistent `sync_queue`. On the wire none of this exists — the states
project onto the payload's `synced`/`deleted` booleans when publishing.

Engine behaviour (`native/service/src/sync/engine.rs`, all local-only):

- **Incremental pull**: `created_at == updatedAt` makes the replaceable
  timestamp exactly the merge key, so the service keeps a last-seen cursor
  (`app_settings` key `sync.cursor_s`) and pulls `since = cursor − 1h`
  (overlap absorbs clock skew). A fresh install pulls everything.
- **Retry**: failed pushes back off exponentially (5 s · 2^attempts, capped
  at 1 h) and are never dropped; after 5 attempts they also surface in the
  `failed` count and `sync_failures`. Interactive-only signers *park*
  operations (`pending_signature`) without burning attempts.
- **Encryption/signing** go through the active `SignerBackend`; the engine
  never touches key material itself.
