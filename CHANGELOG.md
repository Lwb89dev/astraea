# Changelog

All notable changes to Astraea are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned

- Final Android application ID and production signing setup.
- Dedicated production hardening for additional platforms.

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
