# Architecture

## Design goals

Astraea is organized around four invariants:

1. Calendar operations remain usable without a network or Nostr account.
2. Local persistence completes before any best-effort network publication.
3. Decrypted calendar content never reaches a relay or application log.
4. Relay responses are untrusted until their event ID, signature, author, kind
   and application-specific tags have been verified.

## Layers

```text
Screens and widgets
        │
        ▼
Riverpod providers
        │
        ▼
Application services
        │
        ├── Hive / SharedPreferences / secure storage
        ├── operating-system notifications and home widgets
        └── Nostr relays / Amber external signer
```

### Models

`lib/models` contains plain application data: calendar events, reminders,
accounts, profiles and settings. Persisted event instants are UTC. The event's
IANA timezone is retained separately for authoring and display semantics.

### Providers

`lib/providers` owns reactive application state and mutation ordering. Event
mutations write locally, update reminders, attempt synchronization and finally
refresh exposed state and widgets. Authentication, settings and onboarding are
kept independent so the app remains valid in local-only mode.

### Services

`lib/services` contains infrastructure boundaries:

- `LocalStorageService` owns Hive, preferences, secure key storage and
  iCalendar import/export.
- `NostrService` owns identity operations, NIP-44 encryption/decryption,
  signing, websocket subscriptions and event authentication.
- `CalendarSyncService` coordinates pull, last-write-wins merge, publication
  and deletion tombstones.
- `NotificationService` expands a bounded recurrence window and schedules
  local reminders.
- `HomeWidgetService` gives Android widgets a bounded local occurrence cache.

### UI

`lib/screens` contains Material 3 screens. First launch is a three-step flow:
product/privacy introduction, optional Nostr identity, then explicit relay
selection. The calendar views share one selected/focused-day provider.

## Storage

| Data | Storage | Notes |
| --- | --- | --- |
| Calendar events | Hive | App-private local store; deletion tombstones retained for sync. |
| Private key | Platform secure storage | Never stored in preferences; absent for Amber sessions. |
| Public key and login method | SharedPreferences | Non-secret session metadata. |
| Relay and UI settings | SharedPreferences | User-selected non-secret configuration. |
| Reminder IDs | SharedPreferences | Allows precise cancellation across restarts. |
| Widget occurrence cache | Home Widget shared preferences | Local data visible to the Android launcher widget. |
| Avatar | App-private cache | HTTPS only, content-type and size bounded. |

## Nostr representation

An event is serialized to JSON and self-encrypted with NIP-44. The ciphertext is
published as kind `30078` with a stable `d` tag using the historical
`epochs:<uuid>` prefix for wire compatibility. `updatedAt` is monotonic at
whole-second resolution because Nostr replaceable-event ordering uses seconds.

Every configured sync relay is an explicit read/write target. Metadata profile
lookups may additionally query the documented fallback relays, but calendar
queries and publications always pass their relay list explicitly.

## Conflict and deletion behavior

Incoming valid events are merged by `updatedAt`; the newest version wins. A
delete is an encrypted replacement with `deleted: true`, accompanied by a
NIP-09 request for the preceding concrete event ID. The encrypted tombstone is
left available so another device can learn the deletion even if a relay ignores
NIP-09.

Events remember the public key that owns their sync history. An event already
associated with one account is not republished after switching to another.

## Platform boundary

Android is the supported target. Native Kotlin implements launcher widgets,
deep-link navigation and sensitive clipboard/screenshot handling. Web remains
experimental because browser extensions, IndexedDB, CSP and key storage require
a separate production threat model.
