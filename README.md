<p align="center">
  <img src="assets/icon/icon.png" width="128" alt="Astraea logo">
</p>

<h1 align="center">Astraea</h1>

<p align="center">
  A private, offline-first calendar with optional end-to-end encrypted sync over Nostr.
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter&logoColor=white">
  <img alt="Nostr" src="https://img.shields.io/badge/Nostr-NIP--44%20%C2%B7%20NIP--46-8A2BE2">
  <img alt="License" src="https://img.shields.io/badge/license-GPL--3.0--or--later-blue">
</p>

## About

Astraea keeps the network optional. Events, recurrences, reminders, calendar
views, widgets, imports and exports work locally without an account. Users who
want multi-device synchronization can connect a Nostr identity and explicitly
choose the relays that will store their encrypted calendar.

Calendar contents are NIP-44 self-encrypted before publication. Relay operators
can observe protocol metadata such as the public key, IP address, timestamps and
event sizes, but cannot read event titles, descriptions, locations or reminder
details.

## Features

- **Offline-first calendar** with month, week, day and upcoming-list views.
- **Recurring events** with daily, weekly, monthly and yearly presets.
- **Local reminders** scheduled by the operating system, including recurring
  occurrences and reboot restoration on Android.
- **Optional Nostr sync** using encrypted kind `30078` parameterized-replaceable
  events and NIP-09 deletion requests.
- **Flexible identity** through an imported key, a locally generated account,
  the Amber NIP-55 external signer on Android, or a **NIP-46 remote signer
  ("bunker") on both Android and Linux** — the account private key never
  reaches the device at all.
- **Sync on launch**: every start reconciles with the relays before you touch
  anything, on mobile and on the Linux service alike.
- **Explicit relay choice** during onboarding and in Settings. `nos.lol` and
  `relay.damus.io` are suggestions, not mandatory infrastructure.
- **Personal relay support** as an additional backup destination.
- **Encrypted exports** using PBKDF2-HMAC-SHA256 and AES-256-GCM, alongside
  standard unencrypted iCalendar (`.ics`) import/export.
- **Android home-screen widgets** for daily, weekly and monthly agendas.
- **Timezone-aware storage**: instants are stored in UTC and rendered in the
  selected or device timezone.
- **Light and dark themes**, with dark mode as the privacy-oriented default.

## How synchronization works

1. Every mutation is written to the local Hive store first.
2. When sync is enabled, the event JSON is encrypted to the user's own Nostr
   identity with NIP-44.
3. Astraea signs and publishes a kind `30078` event under a stable `d` tag.
4. Each configured relay must acknowledge the publication before the local
   version is marked as synchronized.
5. Pulls verify the NIP-01 event ID and Schnorr signature, decrypt valid events,
   then merge them using the latest `updatedAt` timestamp.
6. Deletions publish both an encrypted tombstone and a NIP-09 request so other
   devices can learn the deletion even when a relay ignores retractions.

No Astraea server, account service or analytics backend sits in this path.

## Signing without holding a key (NIP-46)

A remote signer keeps the account private key on hardware you control and
answers signing requests over a relay. Astraea stores only a throwaway client
key, which the signer authorizes by public key and can revoke at any time.

```bash
# Linux: connect a bunker (this also logs you in, and enables background
# signing without any key material on the machine).
astraea-service auth connect-bunker      # paste bunker://… on stdin
astraea-service auth status              # signer: remote_nip46, state: ready
```

On Android, and in the Linux app's Settings, the same flow is a
"Sign in with a remote signer" field that takes the `bunker://` string.
Every reply from the signer is checked before it is trusted: kind, author,
NIP-01 event id and Schnorr signature, and — for a signed event — that every
field still matches what Astraea asked to have signed.

## Platform status

| Platform | Status | Notes |
| --- | --- | --- |
| Android | Supported | Primary audited target; Amber (NIP-55), NIP-46 bunker login and home-screen widgets available. |
| Linux desktop | Supported | Flutter app + `astraea-service` daemon (D-Bus, encrypted Nostr sync, browser NIP-07 login, NIP-46 bunker login with background signing), GNOME Shell extension, modular packaging (deb/rpm/PKGBUILD/Flatpak/tarball). |
| Web | Experimental | Builds are scaffolded, but sensitive production use needs a browser/CSP review. |
| iOS | Not configured | Platform project and release hardening are not included yet. |

### Linux in short

```bash
./scripts/install-dev.sh        # user-session dev install (no root)
flutter run -d linux            # the desktop UI (talks to the service over D-Bus)
astraea-service diagnostics     # paths, D-Bus, database, relays — no secrets
```

The background service owns storage, sync, auth and notifications; the
Flutter app, the GNOME extension and the COSMIC applet are thin D-Bus
frontends. Start from [docs/linux-architecture.md](docs/linux-architecture.md),
[docs/packaging.md](docs/packaging.md) and
[docs/troubleshooting.md](docs/troubleshooting.md).

## Getting started

### Requirements

- Flutter stable with Dart `3.12.2` or newer
- JDK 17
- Android SDK 36 for Android builds
- A configured device or emulator

Check the local toolchain, install locked dependencies and run Astraea:

```bash
flutter doctor
flutter pub get --enforce-lockfile
flutter run
```

### Quality checks

```bash
dart format --output=none --set-exit-if-changed lib test
bash tool/check_repository_hygiene.sh
flutter analyze
flutter test
flutter build apk --debug
```

The test suite covers NIP-44 official vectors, NIP-46 connection-string and
stored-session validation, iCalendar round trips, recurrence expansion, relay
settings and the first-launch onboarding flow. The Rust service adds its own
`cargo test --all-targets` suite (sync engine, login bridge, wire compat).

## Project structure

```text
lib/
  models/       Calendar, account, profile and settings data
  providers/    Riverpod state and application orchestration
  screens/      Calendar, editor, onboarding and settings UI
  services/     Storage, Nostr, sync, notifications, widgets and exports
  utils/        NIP-44, recurrence, iCalendar, formatting and validation
android/        Android host app and native home-screen widgets
linux/          Flutter Linux runner (single-instance, astraea:// deep links)
native/         astraea-service Rust daemon, D-Bus XML, COSMIC applet
extensions/     GNOME Shell extension (thin D-Bus frontend)
packaging/      deb, rpm, Arch, Flatpak, tarball definitions
scripts/        Linux build/install/packaging/version scripts
test/           Unit, crypto-vector, wire-compat and widget tests
web/            Experimental Flutter web shell
docs/           Architecture, wire contract, threat model, packaging, releases
```

## Release builds

Release builds intentionally fail unless a dedicated keystore is configured;
the project never falls back to Android's debug signing identity. See
[Releasing](docs/RELEASING.md) for the complete checklist.

Never commit `android/key.properties`, a keystore, private Nostr keys, service
credentials or local environment files. The repository ignore rules cover the
common variants, but release operators remain responsible for reviewing every
staged change.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Linux architecture](docs/linux-architecture.md) ·
  [D-Bus API](docs/dbus-api.md) ·
  [Authentication](docs/authentication.md) ·
  [Nostr wire contract](docs/nostr-sync.md)
- [Packaging](docs/packaging.md) ·
  [Threat model](docs/threat-model.md) ·
  [Troubleshooting](docs/troubleshooting.md) ·
  [Release process](docs/release-process.md)
- [Privacy policy](PRIVACY.md)
- [Security policy](SECURITY.md)
- [Security audit](docs/SECURITY_AUDIT.md)
- [Contributing](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

## Contributing

Bug reports and focused pull requests are welcome. Please read
[CONTRIBUTING.md](CONTRIBUTING.md) and run the full quality checks before
opening a pull request. Security vulnerabilities must follow the private
process in [SECURITY.md](SECURITY.md), not a public issue.

## Acknowledgements

Astraea is part of the Echoes ecosystem and is built on open protocols and
open-source projects including Flutter, Nostr, Riverpod, Hive, Amber and
`dart_nostr`.

## License

Copyright holders license Astraea under the
[GNU General Public License v3.0 or later](LICENSE).
