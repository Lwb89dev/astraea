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
        │  bus name  com.lwb89dev.Astraea      │
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
busctl --user introspect com.lwb89dev.Astraea /com/lwb89dev/Astraea
busctl --user call com.lwb89dev.Astraea /com/lwb89dev/Astraea \
  com.lwb89dev.Astraea.Calendar1 GetVersion

# desktop app
flutter run -d linux
```
