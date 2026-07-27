# Astraea Linux desktop architecture

Status: implementation in progress on `feature/linux-desktop-integration`.
Audience: contributors working on the Linux desktop integration.

## Components

```
┌────────────────────┐  ┌─────────────────────┐  ┌────────────────────┐
│  Astraea Desktop   │  │ GNOME Shell         │  │ COSMIC applet      │
│  (Flutter, GTK)    │  │ extension (GJS)     │  │ (Rust, libcosmic)  │
│  full calendar UI  │  │ top-bar agenda +    │  │ top-bar agenda +   │
│                    │  │ quick event form    │  │ quick event form   │
└─────────┬──────────┘  └──────────┬──────────┘  └─────────┬──────────┘
          │  D-Bus (session bus)   │                       │
          └────────────┬───────────┴───────────────────────┘
                       ▼
        ┌──────────────────────────────────────┐
        │ Astraea Service (Rust daemon)        │
        │  bus name  …Astraea.Service          │
        │  path      /com/lwb89dev/Astraea     │
        │  ifaces    …Astraea.Calendar1        │
        │            com.lwb89dev.NostrAccount1│
        │                                      │
        │  SQLite (XDG data dir)               │
        │  sync queue + relay pool (nostr-sdk) │
        │  browser-auth bridge (127.0.0.1)     │
        │  signer abstraction                  │
        │  desktop notifications               │
        └───────┬───────────────┬──────────────┘
                │               │
        Secret Service      Nostr relays (wss)
        (keyring)           kind 30078 + kind 5
```

Responsibilities:

- **Astraea Service** (`native/service`, binary `astraea-service`) is the
  single owner of the Linux-side database, the Nostr connections, the sync
  queue, authentication sessions and desktop notifications. It exposes a
  versioned D-Bus API on the session bus and is started on demand via D-Bus
  activation / systemd user service.
- **Astraea Desktop** (the existing Flutter app with a `linux/` runner) is a
  full-featured client of the service. On Linux it does **not** open Hive or
  relay connections itself; it talks D-Bus. On Android nothing changes.
- **GNOME Shell extension** (`extensions/gnome`) and **COSMIC applet**
  (`native/cosmic-applet`) are thin frontends: query, render, send commands,
  listen to signals, open the desktop app. They never touch relays, keys or
  the database.

## Process lifecycle

- `com.lwb89dev.Astraea.service` (D-Bus activation) declares
  `SystemdService=astraea.service`, so the session `systemd --user` supervises
  the daemon when present; on systemd-less systems the session bus spawns the
  binary directly (documented fallback, same file).
- The daemon exits after an idle period (default 30 min) when there are no
  connected clients, no pending sync operations and no reminder due within
  the idle horizon; any D-Bus call re-activates it.
- SIGTERM: stop accepting work, flush the sync queue best-effort with a
  bounded deadline, checkpoint + close SQLite, exit 0.
- Duplicate instances are impossible by construction: owning the well-known
  bus name is the singleton lock.

## Data flow: creating an event from the shell popup

1. Frontend calls `CreateEvent(json)` on `Calendar1`.
2. Service validates the draft, writes the event to SQLite in a transaction
   (`sync_state = local_only`), enqueues a `publish` row in `sync_queue`.
3. Service emits `EventsChanged`; every frontend (Flutter UI, extension,
   applet) refreshes the affected range.
4. The sync worker picks the queue row: signs (via the active signer
   backend), publishes to the configured relays, retries with exponential
   backoff on failure. State transitions
   `local_only → pending_signature → pending_publish → publishing → synced`
   are persisted and surfaced through `SyncStatusChanged`.
5. If the device is offline nothing is lost: the queue drains when
   connectivity returns.

## Storage (XDG)

| Purpose  | Path                                            |
| -------- | ----------------------------------------------- |
| Database | `$XDG_DATA_HOME/astraea/astraea.db` (fallback `~/.local/share/…`) |
| Config   | `$XDG_CONFIG_HOME/astraea/`                     |
| Cache    | `$XDG_CACHE_HOME/astraea/`                      |
| Logs     | `$XDG_STATE_HOME/astraea/logs/` (rotated, bounded) |
| Runtime  | `$XDG_RUNTIME_DIR/astraea/`                     |

Secrets (delegated app keys, auth session material) live exclusively in the
freedesktop **Secret Service** (GNOME Keyring, KWallet ≥ 5.97, or any
compatible provider). Never in SQLite, JSON, config files or logs.

## Architecture decision records

### ADR-001 — Service language: Rust with the `nostr` crate family

The Dart Nostr core (NIP-44 over pointycastle + `dart_nostr`) stays
authoritative for Android. The Linux daemon is written in Rust because it
must be a small, dependency-light, long-lived session binary that also
serves the COSMIC applet ecosystem; shipping a headless Flutter/Dart runtime
as a daemon would balloon packaging and memory for no functional gain.

The wire format is deliberately tiny (kind 30078, `d` tag `epochs:<uuid>`,
NIP-44 v2 self-encrypted JSON payload), so the compatibility risk is managed
by contract, not by sharing code:

- `docs/nostr-sync.md` is the normative wire contract;
- the Rust crate re-runs the same official NIP-44 vectors used by
  `test/nip44_test.dart`;
- shared JSON fixtures assert that both implementations produce/accept the
  same event payloads.

Migration strategy: no second "complete" implementation exists — the Dart
side keeps its mobile sync engine, the Rust side owns Linux. If they ever
diverge, the contract + fixtures fail CI first.

### ADR-002 — D-Bus payloads: versioned JSON strings for domain objects

Domain objects (events, calendars, drafts, patches) cross D-Bus as UTF-8
JSON strings carrying `"schemaVersion": 1`. Status/summary payloads use
plain `a{sv}` where flat. Rationale: three client languages (Dart, GJS,
Rust) with very different D-Bus struct ergonomics; JSON keeps one schema,
one validator, one evolution rule (unknown fields ignored, breaking changes
bump `Calendar1` → `Calendar2`). Inputs are size-limited (1 MiB) and
schema-validated by the service.

### ADR-003 — Flutter Linux backend: provider-level swap, no forked UI

The existing Riverpod providers are the seam. On Linux the app overrides the
storage/sync providers with D-Bus-backed implementations from
`lib/desktop/`; screens/widgets stay shared with Android. Direct database
reads from the Flutter process are forbidden when the service is reachable.
A mock backend (in-memory) supports UI development without a service.

### ADR-004 — Account service extraction path

Identity/authentication lives in its own Rust module tree (`account/`)
behind traits (`SignerBackend`, `AccountStore`) and its own D-Bus interface
`com.lwb89dev.NostrAccount1` on the same object. Nothing in `account/`
imports calendar types. Extracting a future shared
`lwb-nostr-account-service` for Echoes/Kairos = moving the module to its own
crate + bus name and pointing `astraea-service` at it; the D-Bus interface
name is already product-neutral.

### ADR-005 — Calendars are local-first; the wire format is unchanged

The Android wire payload has no `calendarId`. The service supports multiple
calendars locally (table + `calendar_id` column). Published payloads gain an
optional `calendarId` field, which old clients ignore — and, on their next
edit, drop (LWW). This is acceptable: calendar membership degrades to the
default calendar rather than corrupting data. Full multi-calendar sync
across devices is deferred until the mobile app understands the field;
documented in docs/nostr-sync.md.

### ADR-006 — Browser auth is the login path; signing is pluggable

NIP-07 exists only inside browsers, so login = local HTTP callback bridge
(127.0.0.1, random port, state/nonce/expiry, single use) + a page that uses
`window.nostr`. A one-time login proves pubkey ownership; persistent signing
is a separate concern behind `SignerBackend`:
`BrowserNip07Signer` (per-signature browser round-trip, fallback),
`RemoteSigner` (NIP-46 bunker, preferred for continuous use),
`LocalDelegatedSigner` (app-scoped key in Secret Service, revocable, never
the main nsec), `ReadOnlySigner`. See docs/authentication.md.

### ADR-007 — Event attendees: invite/accept/decline, not Echoes' unilateral share

Requirement: a user adds a person to an event (by npub, NIP-05, or a search
against their own contact list); that person must explicitly accept or
decline; the inviter is notified of the outcome. Researched the sibling
project Echoes (`/home/antona89/Documenti/vscode/echoes`) first, since its
own docs name Astraea as *its* architectural reference and it ships the only
existing person-to-person Nostr flow in the family. Finding: **Echoes has no
accept/decline step** — sharing a note is a unilateral push (the recipient
gets the full decrypted content immediately; their only lever is a
one-way, irrevocable "leave" *after* receiving it) and there is no
notification mechanism at all (zero notification packages). So half of this
requirement — the actual invite/response/notify lifecycle — is new design,
not something to port. What *is* directly reused, because it is
security-reasoned and worth being consistent about across the ecosystem
(ADR-004):

- **Person lookup**, three paths, exactly Echoes' triad
  (`echoes/lib/services/nostr_service.dart`,
  `echoes/lib/screens/widgets/share_note_sheet.dart`):
  1. npub / 64-hex pubkey — local bech32 decode, no network.
  2. NIP-05 (`name@domain`) — `.well-known/nostr.json` over HTTPS only, no
     redirect-follow without re-validating the target is still `https`,
     bounded timeout and response size. Explicitly *not* proof of identity
     (a domain operator's claim), so the picker must show a confirmation
     step with the resolved npub before an invite is sent — same reason
     Echoes shows one before sharing.
  3. Own contact list (kind 3) + batched kind-0 profile fetch, filtered
     **client-side** by name/npub substring. Deliberately no NIP-50
     relay-wide name search or directory service: an unverified name match
     is an impersonation risk when getting the wrong recipient means
     leaking a calendar event to a stranger — Echoes rejected it for the
     same reason (`echoes/lib/utils/constants.dart`), and it applies here
     unchanged.
- **Transport substrate**: kind 30078 (already the calendar event kind —
  NIP-78 application data, reused for this exactly as Echoes reuses it for
  content/edit/control alike), NIP-44 v2 encrypted **per recipient**
  (never a shared key), addressed with a `p` tag to the recipient and a
  **deterministic `d` tag** so a re-invite/re-response replaces its own
  relay slot instead of accumulating: `astraea-invite:v1:<eventId>` (owner
  → invitee) and `astraea-invite-response:v1:<eventId>` (invitee → owner).
  Every payload carries a `_astraeaInvite` sentinel key — Echoes'
  `_echoesControl` pattern — so the same "gather everything `p`-tagging me,
  decrypt, verify the *signed* author, dispatch on the sentinel" ingestion
  loop handles both the invite and its response.
- Payload is a purpose-built subset (title/start/end/timezone/allDay/
  location/inviter), never the full internal `Event` — no `calendarId`,
  `localRevision` or `syncState` leaks to the invitee, mirroring
  `Note.toShareJson()`'s discipline of stripping owner-only bookkeeping.

New, because nothing to port exists:

- **State machine** on `attendees` (a field the original data-model spec
  already reserved but never implemented): each entry is
  `{pubkey, status: invited|accepted|declined}`. An outgoing invite is just
  an attendee row on the inviter's own event — no separate table. An
  *incoming* invite has no local event yet, so it lives in a small
  dedicated store (`invitations` table in the service; a Hive box on
  mobile) until accepted (which creates the local event, calendarId chosen
  by the invitee, `sourceDevice`/ownership local to them) or declined
  (nothing is stored beyond a short-lived dedupe record).
- **Notification of the outcome**: on Linux this is a real freedesktop
  desktop notification (docs/dbus-api.md `NotificationRaised`, §18 of the
  original brief) fired when a response event for one of the inviter's own
  pending attendee rows arrives — something Echoes structurally cannot do
  (mobile-only, no notification plugin at all).

Unlike Echoes' ADR-E-005 (which keeps its note-sharing protocol Dart-only,
citing the risk of a second implementation before a wire-fixture suite
exists), Astraea already carries that risk for the *whole* calendar-sync
wire format (ADR-001) and already has the guardrail Echoes doesn't: shared
JSON fixtures asserted by both `test/` and `native/service/tests/`
(docs/nostr-sync.md). The invite protocol is specified in
docs/nostr-sync.md alongside the calendar event contract and implemented in
both the Dart mobile engine and the Rust service under the same
fixture-parity discipline — not deferred to one side.

## Repository layout (delta)

```
lib/desktop/            D-Bus client + Linux provider overrides (Dart)
linux/                  Flutter Linux runner (generated + kept)
native/service/         astraea-service (Rust)
native/dbus/            introspection XML (normative copies)
native/cosmic-applet/   COSMIC applet (Rust scaffold)
extensions/gnome/       GNOME Shell extension (GJS)
packaging/{deb,rpm,arch,flatpak,appimage,common}/
assets/{desktop,appstream}/   desktop entry, metainfo
scripts/                build-*.sh, install-dev.sh, check-versions.sh
docs/                   this file + dbus-api, authentication, nostr-sync,
                        packaging, threat-model, gnome-extension, …
```

Existing directories are untouched; Android build remains green.

## Development quickstart

```bash
# service
cargo build --manifest-path native/service/Cargo.toml
./scripts/install-dev.sh            # user-level install (units, desktop entry)
systemctl --user daemon-reload
systemctl --user restart astraea.service
journalctl --user -u astraea.service -f

# poke the API
busctl --user introspect com.lwb89dev.Astraea.Service /com/lwb89dev/Astraea
busctl --user call com.lwb89dev.Astraea.Service /com/lwb89dev/Astraea \
  com.lwb89dev.Astraea.Calendar1 GetVersion

# desktop app
flutter run -d linux
```
