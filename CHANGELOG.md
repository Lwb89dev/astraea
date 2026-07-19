# Changelog

All notable changes to Astraea are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned

- Final Android application ID and production signing setup.
- Dedicated production hardening for additional platforms.

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
