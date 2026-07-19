# Astraea D-Bus API

Bus: **session**. Well-known name: `com.lwb89dev.Astraea`.
Object path: `/com/lwb89dev/Astraea`.
Interfaces: `com.lwb89dev.Astraea.Calendar1`, `com.lwb89dev.NostrAccount1`.

Normative introspection XML lives in
[`native/dbus/com.lwb89dev.Astraea.Calendar1.xml`](../native/dbus/com.lwb89dev.Astraea.Calendar1.xml)
and
[`native/dbus/com.lwb89dev.NostrAccount1.xml`](../native/dbus/com.lwb89dev.NostrAccount1.xml).

## Conventions

- Domain objects travel as UTF-8 **JSON strings** (`s`) with a top-level
  `"schemaVersion": 1` (ADR-002). Unknown fields must be ignored by all
  clients. Breaking changes bump the interface suffix (`Calendar1` →
  `Calendar2`); the old interface keeps working for one release cycle.
- Timestamps: Unix seconds UTC (`x`, int64) on the bus; RFC 3339 strings
  inside JSON payloads. Dates: `YYYY-MM-DD` strings.
- Ids: service-generated UUIDv4 strings. The local id is authoritative; the
  Nostr event id is metadata (an unpublished event already has a local id).
- Errors: `com.lwb89dev.Astraea.Error.<Name>` with
  `NotFound`, `InvalidArgument`, `NotAuthenticated`, `SignerUnavailable`,
  `Database`, `PayloadTooLarge`, `Internal`.
- Input limits: any JSON argument > 1 MiB fails with `PayloadTooLarge`.
- Slow work (network, signing) never blocks the bus: mutating calls return
  after the local commit; publication progress is reported via signals.

## com.lwb89dev.Astraea.Calendar1

### Methods

| Method | Signature | Notes |
| --- | --- | --- |
| `GetVersion` | `() → (s version)` | service semver |
| `GetServiceStatus` | `() → (s json)` | `{serviceVersion, databaseStatus, networkStatus, syncStatus, authenticated, activeAccount, lastSync, pendingOperations, schemaVersion}` |
| `GetAgenda` | `(x start, x end, as calendarIds) → (s json)` | expanded occurrences in `[start,end)`; empty `calendarIds` = all |
| `GetDay` | `(s date, as calendarIds) → (s json)` | convenience over `GetAgenda` |
| `GetWeek` | `(s startDate, as calendarIds) → (s json)` | 7 days from `startDate` |
| `GetMonth` | `(u year, u month, as calendarIds) → (s json)` | |
| `GetEvent` | `(s eventId) → (s json)` | master event, not an occurrence |
| `CreateEvent` | `(s draftJson) → (s eventId)` | commits locally, queues publish |
| `UpdateEvent` | `(s eventId, s patchJson) → (s json)` | RFC 7396-style merge patch |
| `DeleteEvent` | `(s eventId) → ()` | tombstone + queued NIP-09 |
| `GetCalendars` | `() → (s json)` | |
| `CreateCalendar` | `(s draftJson) → (s calendarId)` | |
| `UpdateCalendar` | `(s calendarId, s patchJson) → (s json)` | |
| `DeleteCalendar` | `(s calendarId) → ()` | events move to default calendar |
| `SyncNow` | `() → (s operationId)` | async; completion via `SyncStatusChanged` |
| `GetSyncStatus` | `() → (s json)` | `{state, lastSyncAt, pending, failed, relays:[{url,state}]}` |
| `OpenDesktop` | `(s view, s targetId, s date) → ()` | launches/raises the Flutter app via `astraea://` |
| `GetSettings` | `() → (s json)` | relays, timezone, notifications, … |
| `UpdateSettings` | `(s patchJson) → (s json)` | |

Occurrence JSON (elements of the `GetAgenda`/`GetDay`/... result array):

```json
{
  "schemaVersion": 1,
  "eventId": "3d1f…",
  "occurrenceStart": "2026-07-19T09:00:00Z",
  "occurrenceEnd": "2026-07-19T10:00:00Z",
  "title": "…", "location": "…", "allDay": false,
  "calendarId": "default", "color": "#3F51B5",
  "timezone": "Europe/Rome",
  "syncState": "synced", "status": "confirmed"
}
```

Event draft (accepted by `CreateEvent`; `title`, `start`, `end` required):

```json
{
  "schemaVersion": 1,
  "title": "…", "description": "…", "location": "…", "url": "…",
  "start": "2026-07-19T09:00:00Z", "end": "2026-07-19T10:00:00Z",
  "timezone": "Europe/Rome", "allDay": false,
  "calendarId": "default", "color": "#3F51B5",
  "recurrence": {"type": "weekly", "until": "2026-12-31T00:00:00Z"},
  "reminders": [{"minutesBefore": 10}]
}
```

### Signals

| Signal | Signature | Emitted when |
| --- | --- | --- |
| `EventsChanged` | `(as eventIds)` | any event mutated (local or via sync); empty array = full refresh |
| `CalendarsChanged` | `()` | |
| `SyncStatusChanged` | `(s json)` | same payload as `GetSyncStatus` |
| `SettingsChanged` | `(s json)` | |
| `NotificationRaised` | `(s eventId, s title, x fireAt)` | a reminder fired |
| `ServiceError` | `(s code, s message)` | non-fatal background failure |

## com.lwb89dev.NostrAccount1

Product-neutral identity interface (ADR-004 — future shared account
service for Astraea/Echoes/Kairos).

### Methods

| Method | Signature | Notes |
| --- | --- | --- |
| `BeginBrowserLogin` | `() → (s json)` | `{sessionId, url, expiresAt}`; service opens the browser itself and also returns the URL |
| `CancelBrowserLogin` | `(s sessionId) → ()` | |
| `GetAuthenticationStatus` | `() → (s json)` | `{authenticated, pubkey, npub, signer, signerState, readOnly}` |
| `Logout` | `() → ()` | wipes session + Secret Service entries |
| `GetAccounts` | `() → (s json)` | |
| `SwitchAccount` | `(s accountId) → ()` | |

### Signals

| Signal | Signature |
| --- | --- |
| `AuthenticationChanged` | `(s json)` — same payload as `GetAuthenticationStatus` |

## Examples

```bash
busctl --user call com.lwb89dev.Astraea /com/lwb89dev/Astraea \
  com.lwb89dev.Astraea.Calendar1 GetVersion

busctl --user call com.lwb89dev.Astraea /com/lwb89dev/Astraea \
  com.lwb89dev.Astraea.Calendar1 CreateEvent s \
  '{"schemaVersion":1,"title":"Demo","start":"2026-07-20T09:00:00Z","end":"2026-07-20T10:00:00Z","timezone":"Europe/Rome"}'

# GetDay('2026-07-20', []) — "sas" + array length 0
busctl --user call com.lwb89dev.Astraea /com/lwb89dev/Astraea \
  com.lwb89dev.Astraea.Calendar1 GetDay sas '2026-07-20' 0

gdbus monitor --session --dest com.lwb89dev.Astraea
```

## Compatibility rules

1. Never remove or re-type a method/signal within `Calendar1`.
2. New optional JSON fields are always allowed; clients ignore unknowns.
3. Clients must tolerate: timeout, empty result, name-not-owned (service
   not installed), and `schemaVersion` newer than their own (render what
   they understand).
4. The GNOME extension and COSMIC applet must start the service via D-Bus
   activation (plain method call), never by spawning the binary.
