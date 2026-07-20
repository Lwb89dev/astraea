# Linux desktop integration — progress checklist

Branch: `feature/linux-desktop-integration`.
This file tracks the phased implementation plan from the Linux integration
brief. Update it at the end of every phase.

## Phase 0 — Repository audit ✅

Findings (2026-07-19):

- Single Flutter package `astraea` (version `0.1.1+2`, Dart SDK `^3.12.2`),
  Android is the primary target; `web/` experimental; **no `linux/` runner**.
- State management: Riverpod 3 (`AsyncNotifier`). Nostr: `dart_nostr` 10.
- Persistence: Hive box `epochs_events` (events as JSON maps),
  SharedPreferences (settings, legacy `epochs.*` keys), and
  `flutter_secure_storage` for the private key (`epochs.privkey`).
- Wire format: kind **30078** parameterized-replaceable events, `d` tag
  `epochs:<uuid>`, content = `Event.toJson()` JSON **NIP-44 self-encrypted**
  (own implementation over pointycastle, official test vectors in
  `test/nip44_test.dart`). Deletion = encrypted tombstone (same `d` tag)
  + NIP-09 kind-5 for the previous concrete event id. Merge: last-write-wins
  on `updatedAt`; `created_at` of the 30078 event is `updatedAt`.
- Identity: local key (imported/generated) or Amber (NIP-55, Android only).
- Event model has **no calendarId** today (single implicit calendar) and no
  attendees/status/visibility. Recurrence: presets daily/weekly/monthly/
  yearly + optional end (no full RRULE).
- CI: one workflow (format, hygiene script, analyze, test). No packaging.
- License GPL-3.0-or-later. Namespace for D-Bus/AppStream:
  `com.lwb89dev.Astraea` (developer: Lwb89dev).

Risks identified:

1. Duplicating Nostr logic (Dart ↔ Rust) can fork the wire format —
   mitigated by a written wire contract (docs/nostr-sync.md) plus
   cross-implementation compatibility tests (NIP-44 vectors + payload
   round-trip fixtures shared between `test/` and the Rust crate).
2. `calendarId` does not exist on the wire; adding it naively would be
   erased by older Android clients on their next LWW write. Kept
   local-first with a documented forward-compat rule (ADR-005).
3. GNOME Shell is not installed on the dev machine (COSMIC): the extension
   is validated by lint + mock D-Bus tests + documented manual test plan,
   not by a local nested shell.
4. Flatpak sandbox vs. session D-Bus service ownership — documented
   trade-off in docs/packaging.md.

## Phase 1 — Architecture ✅

- [x] docs/linux-architecture.md (components, diagrams, ADRs)
- [x] docs/dbus-api.md + introspection XML (native/dbus/)
- [x] Model boundaries + shared-identity extraction strategy (ADR-004)

## Phase 3 — Minimal service (Rust) ✅

- [x] native/service crate: `com.lwb89dev.Astraea.Service`, Calendar1 +
      NostrAccount1 interfaces (account iface stubbed until phase 6)
- [x] SQLite (XDG paths, WAL, versioned migrations, backup-before-migrate,
      corruption quarantine)
- [x] CRUD events/calendars via D-Bus + EventsChanged/CalendarsChanged
- [x] systemd user unit (hardened) + D-Bus activation file (+ documented
      non-systemd fallback: dbus-daemon spawns Exec directly)
- [x] CLI: status / sync / diagnostics / doctor / db migrate / auth
- [x] 20 unit tests (model, recurrence parity with Dart, store, migrations)
- Verified live: busctl create→GetDay→signals, activation via systemd user
  manager, SIGTERM graceful shutdown, idle-exit policy.

## Phase 4 — Flutter Linux ✅

- [x] `flutter create --platforms=linux` runner; app id
      `com.lwb89dev.Astraea`; single-instance GTK runner forwarding
      astraea:// deep links over a method channel
- [x] lib/desktop: DbusCalendarClient (+ListEvents on the service),
      ServiceEventCodec, DesktopEventsNotifier override, status/calendar
      providers — web/Android untouched via conditional import
- [x] Desktop shell: calendars sidebar (wide windows), service/sync/auth
      status tile, Sync-now action; full-screen recovery UI when the
      service is unreachable
- [x] Deep links: astraea://calendar/{day,week,month,agenda}/DATE,
      astraea://event/ID, astraea://new-event?date=…
- Verified: flutter analyze clean, 78 tests green, Linux release build,
  Android debug APK still builds, single-instance forwarding tested.
- Note: the mobile onboarding is skipped on desktop (service owns
  relays/identity from phase 6 on).

## Phase 5 — GNOME Shell extension ✅

- [x] extensions/gnome/astraea@lwb89dev — ESM extension, GNOME 45–48
- [x] Indicator + day agenda popup (‹/today/›), quick-add form
      (title/start/end/all-day), open-event / open-app via OpenDesktop
- [x] Async D-Bus client with 10 s timeouts, EventsChanged signal updates
      (no polling; refresh-on-open only), service-absent status line
- [x] gettext (en template + it), keyboard focus for the quick form
- [x] Clock-menu integration decision recorded in docs/gnome-extension.md
      (standalone indicator now; optional guarded DateMenu adapter later)
- Note: dev machine runs COSMIC → runtime validation happens on GNOME
  VMs per the manual test plan in docs/gnome-extension.md; CI lints JS.

## Phase 6 — Browser auth ✅

- [x] Login session (state + signed challenge as nonce, 5-min expiry) with a
      single-use 127.0.0.1 listener on a kernel-chosen port
- [x] Local login page (NIP-07, strict CSP, names the requesting app),
      kind-22242 verification: state, challenge tag, created_at freshness,
      NIP-01 id + Schnorr signature
- [x] Secret Service storage (delegated key only; SQLite holds pubkeys);
      signer abstraction (read-only/browser/remote-NIP-46/local-delegated),
      `SetSigner` on NostrAccount1, `auth provision-key` via stdin
- [x] AuthenticationChanged emitted from async completions; accounts CRUD
      wired to the existing `accounts` table
- Verified: cargo check clean, 26 tests green (3 integration tests in
  tests/login_bridge.rs: round trip, bad signature rejected, cancellation).
- Notes: login sessions are in-memory by design (the `auth_sessions` table
  stays reserved for future remote-signer sessions); a hardware signer is a
  documented future backend, not a stub enum variant.

## Phase 7 — Nostr sync in the service ✅

- [x] `sync/` module: wire codec for the kind-30078 contract, relay
      transport trait over the `nostr-sdk` pool, engine with pull → LWW
      merge → push (tombstone + NIP-09 double deletion, all-relays
      acceptance rule, exponential backoff capped at 1 h, parked
      `pending_signature` ops that never burn attempts)
- [x] Incremental pull cursor (`sync.cursor_s`, 1 h skew overlap);
      SignerBackend extended with NIP-44 self-encrypt/decrypt (the engine
      never touches key material)
- [x] D-Bus: real `SyncNow` (operation id), live `GetSyncStatus` +
      `SyncStatusChanged`, relay validation in `UpdateSettings`
      (wss-only, no credentials/fragment, persisted to `nostr_relays`),
      `GetServiceStatus` reports network/auth; mutations nudge the engine
- [x] Wire-compat fixtures shared with Dart
      (`test/fixtures/wire_payloads.json` asserted by BOTH
      `test/wire_compat_test.dart` and
      `native/service/tests/wire_compat.rs`); Rust now also passes the
      official NIP-44 vectors used by `test/nip44_test.dart`
- Verified: 46 Rust tests green (9 engine integration tests over a fake
  relay: publish, tombstone+NIP-09, partial acceptance, offline recovery,
  LWW pull, junk/foreign-event screening), flutter analyze clean,
  84 Dart tests green.

## Phase 8 — Packaging ✅

- [x] One staged `/usr` tree (`scripts/build-linux.sh`) feeding every
      format; desktop entry (validated), AppStream metainfo (validated,
      screenshot placeholder documented), hicolor icons generated from
      assets/icon at build time, `x-scheme-handler/astraea` MIME
- [x] Modular DEBs (`scripts/build-deb.sh` → astraea-service /
      astraea-desktop / astraea-gnome-shell-extension with proper
      Depends/Recommends); maintainer scripts cache-refresh only,
      headless-safe — built and validated locally
- [x] RPM spec with the same three subpackages (Fedora + openSUSE macro
      notes, rpmlint hook, builds from the staged tree — rationale in the
      spec header) + `scripts/build-rpm.sh`
- [x] Arch PKGBUILD (source build, `--locked` cargo, no /usr/libexec)
- [x] Flatpak manifest (GUI only, single `--talk-name` grant; the
      in-sandbox-service trade-off is documented and rejected)
- [x] Relocatable tarball + `install.sh` (`--prefix`/`--user`/`--dry-run`/
      `--uninstall` with recorded manifest; user data never deleted) —
      dry-run exercised locally; optional AppImage script with its
      documented integration limits
- [x] `scripts/test-packages.sh` + docs/packaging.md (incl. distro test
      matrix); `dist/` gitignored
- Verified: full release staging (flutter + cargo), three .deb built,
  desktop-file-validate + appstreamcli + structural deb checks green.
- Note: rpmbuild/makepkg/flatpak-builder are absent on this machine —
  those artifacts are validated by their scripts on the matching distros
  (docs/packaging.md matrix) and in CI.

## Phase 9 — COSMIC applet ✅ (scaffold; panel UI blocked on libcosmic)

- [x] `native/cosmic-applet` crate: zbus Calendar1 client (methods +
      EventsChanged/SyncStatusChanged signal streams), toolkit-independent
      `AppletState` view model (agenda rows, indicator label, degraded
      states) with unit tests
- [x] Working terminal frontend over the same modules
      (`astraea-cosmic-applet [DATE] [--open]`) — verified live against the
      running service via D-Bus activation on this COSMIC machine
- [x] docs/cosmic-applet.md: what exists, what is deliberately absent
      (libcosmic is git-only/API-unstable — the documented blocked part),
      and the 5-step panel integration plan
- Note: no fake widget code; the panel plugs into `AppletState` when
  libcosmic is packaged.

## Phase 10 — Hardening

- [ ] docs/threat-model.md, troubleshooting, release process
- [ ] CI: cargo fmt/clippy/test, flutter analyze/test, ext lint, packaging jobs
- [ ] Version-coherence check script
