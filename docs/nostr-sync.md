# Nostr sync — wire contract

This document is **normative**. The Dart implementation
(`lib/services/nostr_service.dart`, `lib/services/calendar_sync_service.dart`)
and the Rust implementation (`native/service/src/sync/`) must both conform;
divergence is a bug in whichever side broke the contract.
Shared JSON fixtures live in `test/fixtures/` and are exercised by both test
suites.

**This contract has an external producer.** Kairos (sibling task manager,
same account-key model) publishes kind-30078
`epochs:<uuid>` events in this exact shape to mirror a dated task onto the
user's Astraea calendar — see its
`lib/services/astraea_calendar_mirror.dart`. It writes `id`, `title`,
`description` (prefixed `"Kairos task"`), `startTimeUtc == endTimeUtc` (a
task is a point in time, not a span — renders as a zero-length event),
`timezone: "UTC"`, `isAllDay: false`, `recurrence: null`, `reminders`,
`color`, `createdAt`/`updatedAt`; it never sets `calendarId`, `url`,
`nostrEventId` or `syncOwnerPubkey`, and never reads Astraea's events back
— a one-way mirror, so an edit made to the mirrored event from inside
Astraea is overwritten the next time the task changes in Kairos. Verified
compatible field-by-field against `wire::parse_payload` and
`merge_remote_event` (Rust) as of Astraea 0.3.0 / Kairos's `[Unreleased]`
CHANGELOG entry; **any breaking change to this JSON shape or to the
`epochs:` `d`-tag convention breaks Kairos too**, not just Astraea's own
two clients.

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
- Relay URLs must be `wss://` (recommended) or `ws://`, no userinfo, no
  fragment, ≤ 2048 chars. `ws://` exists for personal/self-hosted relays
  without a TLS certificate (home LAN, `127.0.0.1`); event content stays
  NIP-44 encrypted regardless, but plaintext transport exposes protocol
  metadata (pubkey, timing, sizes) to the local network — clients should
  warn on `ws://`, never reject it outright (docs/threat-model.md).
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

## Attendee invites (ADR-007)

A distinct message family sharing the calendar event's transport substrate
(kind 30078, NIP-44, deterministic `d` tag) but never confused with it: every
invite/response payload carries a `_astraeaInvite` sentinel key, and readers
try this decode *before* the calendar-sync decode, falling back only on a
sentinel miss.

**This is the one place calendar sync's self-encryption rule does not
apply.** Calendar events are NIP-44-encrypted from the account to itself
(sync across the same person's devices); invites and responses are
encrypted from one account to a *different* account, using the same ECDH
primitive keyed on the other party's pubkey (`SignerBackend::nip44_encrypt_to`
/ `nip44_decrypt_from`, distinct from `nip44_self_encrypt`/`nip44_self_decrypt`
— native/service/src/account/signer.rs). An implementation that reused
self-encryption for invites would produce ciphertext only the sender could
read, silently breaking delivery.

Reference implementation: `native/service/src/sync/invite.rs` (codec),
`native/service/src/sync/engine.rs` (`pull_invites`/`push_invites`, wired
into the same `run_once` cycle as calendar sync).

- **Invite** (organizer → invitee), `d` tag `astraea-invite:v1:<eventId>`,
  `p`-tagged to the invitee:
  ```json
  {
    "_astraeaInvite": "invite",
    "eventId": "5f0e8f7a-1111-4222-8333-944444444444",
    "title": "…", "description": "…", "location": "…",
    "startTimeUtc": "2026-07-20T09:00:00.000Z",
    "endTimeUtc": "2026-07-20T10:00:00.000Z",
    "timezone": "Europe/Rome", "isAllDay": false
  }
  ```
  Deliberately a purpose-built subset of the event — never the internal
  representation wholesale (no `calendarId`, `localRevision`, `syncState`):
  an invitee is not a member of the organizer's calendar and must not learn
  its internal bookkeeping.
- **Response** (invitee → organizer), `d` tag
  `astraea-invite-response:v1:<eventId>`, `p`-tagged to the organizer:
  ```json
  { "_astraeaInvite": "response", "eventId": "5f0e8f7a-…", "status": "accepted" }
  ```
  `status` is `accepted` or `declined`.
- **Pull**: filtered by `p`-tag on the account's own pubkey (not `author`,
  unlike calendar sync — invites and responses are authored by *other*
  accounts), own incremental cursor (`app_settings` key
  `sync.invite_cursor_s`, independent of `sync.cursor_s` so neither stream
  gates the other). Every pulled event is re-checked locally for the `p`-tag
  match even though the relay filter already asked for it — relays are
  untrusted.
- **Accepting** an invitation creates an independent local copy of the
  event, owned by the invitee, `sync_state = local_only`. It is a one-time
  snapshot: the organizer's later edits are not propagated automatically.
  Live-shared (co-owned) events are an intentionally out-of-scope follow-up.
- **Declining** creates no local event; only the response is queued.
- A response naming a pubkey that was never actually invited to that event
  (spoofed, or stale after the organizer removed the attendee) is silently
  ignored — `Store::record_attendee_response` returns `None` and no
  notification fires.
- Outgoing invites/responses queue in a dedicated `invite_outbox` table
  (mirrors `sync_queue`'s retry/backoff exactly, but is independent of it —
  an invite is not a calendar event and has no `sync_state` of its own).
- **Scope note**: this pass implements the protocol on the Rust/Linux
  desktop side only. The Dart/Android implementation is a documented
  follow-up, not silently out of sync with this contract — until it lands,
  invites sent by a Linux desktop user are only actionable by another Linux
  desktop user.
