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

## Phase 3 — Minimal service (Rust)

- [ ] native/service crate: D-Bus name, Calendar1 + NostrAccount1 ifaces
- [ ] SQLite (XDG paths, WAL, versioned migrations, backup-before-migrate)
- [ ] CRUD events/calendars via D-Bus + EventsChanged signal
- [ ] systemd user unit + D-Bus activation file
- [ ] CLI: status / diagnostics / doctor / db migrate
- [ ] cargo test (models, db migrations, occurrence expansion)

## Phase 4 — Flutter Linux

- [ ] `flutter create --platforms=linux .` runner, Android untouched
- [ ] lib/desktop: D-Bus client + provider overrides
- [ ] Desktop layout (sidebar, toolbar, views), deep links astraea://
- [ ] Clear error + mock backend when the service is absent

## Phase 5 — GNOME Shell extension

- [ ] extensions/gnome: indicator + calendar/agenda popup, quick add
- [ ] D-Bus proxy with timeouts, signals, service-absent state
- [ ] gettext, a11y, lint

## Phase 6 — Browser auth

- [ ] Login session (state, nonce, expiry) + 127.0.0.1 callback listener
- [ ] Local login page (NIP-07), signature verification
- [ ] Secret Service storage; signer abstraction (browser/remote/delegated/read-only)

## Phase 7 — Nostr sync in the service

- [ ] nostr-sdk relay pool, offline queue, retry/backoff, LWW merge
- [ ] Wire-compat fixtures vs. Dart implementation

## Phase 8 — Packaging

- [ ] deb, rpm (Fedora + openSUSE notes), PKGBUILD, Flatpak manifest,
      tarball + install script, optional AppImage
- [ ] desktop entry, AppStream, icons, MIME/URL handler, systemd user unit

## Phase 9 — COSMIC applet

- [ ] native/cosmic-applet scaffold: D-Bus client, state model, popup

## Phase 10 — Hardening

- [ ] docs/threat-model.md, troubleshooting, release process
- [ ] CI: cargo fmt/clippy/test, flutter analyze/test, ext lint, packaging jobs
- [ ] Version-coherence check script
