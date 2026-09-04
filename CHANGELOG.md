# Changelog

All notable changes to Astraea are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned

- Final Android application ID and production signing setup.
- Dedicated production hardening for additional platforms.

## [1.0.0] - 2026-08-10

First stable release.

Astraea has carried a `0.x` number since the first commit while the storage
format, the Nostr wire contract and the D-Bus API settled. They have now been
stable across several releases, the Linux service and the mobile app agree on
one contract, and the interface has been rebuilt to match. `1.0.0` says that
out loud: from here, breaking any of those is a major-version decision, not a
patch note.

### Added

- Rebuilt interface across every screen, on a shared design system
  (`lib/widgets/astraea_ui.dart`): one set of colour, spacing, radius and
  motion tokens, a single themed surface treatment, and a theme builder that
  both the light and dark palettes are derived from.
- A week view with a real timeline, instead of the month grid reused at a
  different range.
- A bottom navigation bar for switching between month, week, day and list,
  replacing the segmented control at the top of the screen.

### Changed

- Calendar, event details, event editor, onboarding and settings all follow
  the new layout language: grouped translucent surfaces, consistent section
  headers, larger touch targets and a calmer type scale.
- The accent colour chosen in Settings and the light/dark preference continue
  to drive the whole theme; the revamp changes how they are applied, not
  whether they are respected.
- Animations honour the platform's "reduce motion" accessibility setting:
  every transition in the new design system collapses to zero duration when
  the user has asked for that.

## [0.4.1] - 2026-08-10

### Fixed

- The Android widget picker now shows what each widget actually looks like.
  The three providers declared no preview at all, so the picker fell back to
  inflating the live layout — whose list/grid has no data source outside the
  app — and drew an empty box that launchers covered with their own
  cell-footprint grid. Each widget now ships a `previewLayout` (API 31+) with
  static sample content and a rendered `previewImage` for API 24–30, both
  built from the same colours and sample month so they agree.

## [0.4.0] - 2026-08-02

### Added

- NIP-46 remote signer ("bunker") login on **both Android and Linux**. Paste a
  `bunker://` connection string and the account private key never reaches the
  device: Astraea stores only a throwaway client key that the signer
  authorizes by public key and can revoke at any time.
- On Linux the same flow doubles as a login *and* as unattended background
  signing (`astraea-service auth connect-bunker`, or Settings → Account), with
  no key material on the machine — the previously documented alternative to
  provisioning a local delegated key.
- `ConnectRemoteSigner` on the `com.lwb89dev.NostrAccount1` D-Bus interface.
- Forced sync when the app opens, on mobile and on the Linux service alike, so
  the calendar is reconciled with the relays before the user touches anything.
  Amber sessions stay manual on purpose: NIP-55 signing is an intent into
  another app, so an automatic cycle would open Amber on every launch.

### Changed

- Signing and NIP-44 crypto now route through one exhaustive switch over the
  login method, so a new identity mode cannot silently fall through to a
  wrong branch.
- Signed events returned by *any* external signer (Amber or NIP-46) are
  verified field by field against the request, not just checked for a valid
  signature. Previously this held for Amber only.
- The NIP-01 authenticity check (event id **and** Schnorr signature) lives in
  one shared helper used by every code path that reads from a relay.

### Security

- Relay responses now have a **total** memory budget, not only per-event and
  per-count caps: the two multiplied out to hundreds of megabytes a hostile
  relay could make the app hold. This matches the budget the Linux service's
  transport already enforced.
- The local Kairos Unix socket bounds its read buffer *while reading* instead
  of after the fact — a peer that never sent a newline could previously be
  buffered without limit — and adds a concurrent-connection cap plus
  per-connection backpressure so a flood of valid lines cannot spawn unbounded
  concurrent writes.
- The configured relay list is capped (16) on both the service and the mobile
  store, on read as well as write: every relay is an open socket, a publish
  fan-out target, and another operator learning the account pubkey and IP.
- Signing out now also clears the cached profile and the on-disk avatar, drops
  the live remote-signer connection, and (on Linux) closes the bunker sockets.
- Diagnostic logs no longer record the account public key, deep-link targets,
  or full avatar URLs — all of which tie a device log to a specific identity.

### Fixed

- Overlapping sync cycles are prevented: the start-up sync racing a manual tap
  could run two full pull-merge-push passes at once over the same store.
- The automatic sync is now a start-up action rather than a "calendar screen
  mounted" action, so returning to the calendar no longer re-triggers it.
- Version numbers agree again across `pubspec.yaml`, both Rust crates,
  AppStream and the RPM/Arch packaging (0.3.1 had bumped `pubspec.yaml` only).

### Removed

- The placeholder `RemoteSigner` backend that reported "not configured in this
  build" for every operation, superseded by the real implementation.

## [0.3.1] - 2026-07-28

### Added

- Local Kairos → Astraea task bridge on Android and Linux, alongside the
  existing encrypted Nostr mirror.
- Versioned Kairos hand-off contract with idempotent upserts, deletions and
  notification preferences.
- Linux per-user Unix-socket integration for task delivery, with deep-link
  fallback for desktop integrations.
- Linux service-owned reminder scheduler with freedesktop notifications.

### Fixed

- Android day, week and month widgets now refresh their cached data reliably
  and include overlapping and zero-duration events such as Kairos tasks.
- Calendar day boundaries now remain correct across daylight-saving changes.
- Kairos tasks are shown on the correct day and receive a due notification by
  default when no reminder is supplied.
- NIP-07 login on Linux no longer reports a false missing-extension error when
  nos2x injects `window.nostr` late or through its browser-extension origin.
- NIP-07 login discovery remains retryable instead of locking the page after
  a short startup timeout.

### Security

- Local Kairos payloads are size-limited, version-checked and validated before
  persistence; the Linux transport is restricted to the per-user runtime
  socket.
- NIP-07 continues to sign the one-time challenge in the browser; Astraea
  never receives or requests the private key.

## [0.1.1] - 2026-07-19

### Fixed

- Crash on launch in release builds: R8 code shrinking broke WorkManager's
  reflective startup database lookup (a transitive dependency pulled in by
  the home-screen widgets), causing every release install to crash before
  the app UI could load.

## [0.1.0] - 2026-07-19

### Added

- Offline-first month, week, day and list calendar views.
- Event creation, editing, deletion, recurrence, reminders and timezones.
- Optional NIP-44 encrypted Nostr synchronization.
- Local-key, generated-key and Amber authentication.
- Three-step onboarding with explicit relay selection.
- Suggested `nos.lol` and `relay.damus.io` relays plus custom relay support.
- Android daily, weekly and monthly home-screen widgets.
- Plain iCalendar and password-encrypted export/import.
- Profile metadata and avatar display.
- Light and dark themes.

### Security

- Authenticated NIP-01 event verification before decrypting relay data.
- Private keys stored in the platform secure store or retained by Amber.
- Secure `wss://` relay validation and explicit publication targets.
- Android backup and cleartext network traffic disabled.
- Release builds prevented from using the debug signing key.
