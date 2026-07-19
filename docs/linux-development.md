# Linux development guide

How to build, run and debug the three Linux components. Architecture:
docs/linux-architecture.md. D-Bus API: docs/dbus-api.md.

## Prerequisites

- Flutter stable (Dart ≥ 3.12), `flutter config --enable-linux-desktop`
- Rust ≥ 1.85 (rustup or distro package)
- GTK3 dev headers, ninja, cmake, clang (`flutter doctor` will tell you)
- A session D-Bus (any desktop session has one)

## Background service (native/service)

```bash
cargo build --manifest-path native/service/Cargo.toml
cargo test  --manifest-path native/service/Cargo.toml

# install into the user session (binary, systemd user unit, D-Bus activation)
./scripts/install-dev.sh            # or --debug for a debug binary
systemctl --user daemon-reload

# poke it — any call auto-starts the service via D-Bus activation
busctl --user call com.lwb89dev.Astraea.Service /com/lwb89dev/Astraea \
  com.lwb89dev.Astraea.Calendar1 GetVersion
busctl --user introspect com.lwb89dev.Astraea.Service /com/lwb89dev/Astraea

# logs / status
journalctl --user -u astraea.service -f
~/.local/libexec/astraea/astraea-service status
~/.local/libexec/astraea/astraea-service diagnostics
~/.local/libexec/astraea/astraea-service doctor

# remove everything (keeps user data)
./scripts/uninstall-dev.sh
```

Create an event from the shell:

```bash
busctl --user call com.lwb89dev.Astraea.Service /com/lwb89dev/Astraea \
  com.lwb89dev.Astraea.Calendar1 CreateEvent s \
  '{"schemaVersion":1,"title":"Demo","start":"2026-07-20T09:00:00Z","end":"2026-07-20T10:00:00Z","timezone":"Europe/Rome"}'
```

Watch the signals another client would receive:

```bash
gdbus monitor --session --dest com.lwb89dev.Astraea.Service
```

The database lives in `$XDG_DATA_HOME/astraea/astraea.db` (WAL mode). Never
edit it while the service runs; use the D-Bus API.

## Desktop app (Flutter)

```bash
flutter run -d linux          # debug, hot reload
flutter build linux --release # bundle in build/linux/x64/release/bundle/
```

On Linux the app swaps its events backend for the D-Bus client
(`lib/desktop/`, ADR-003): the service must be installed (see above) or the
app shows the "service unavailable" screen with a retry button. Android
behaviour is untouched — the overrides only activate on `Platform.isLinux`.

Deep links (single instance; a second launch forwards the URI):

```bash
./build/linux/x64/release/bundle/astraea 'astraea://calendar/day/2026-07-20'
./build/linux/x64/release/bundle/astraea 'astraea://new-event?date=2026-07-21'
```

## Quality gates (run before pushing)

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze && flutter test
flutter build linux --release
flutter build apk --debug          # Android must stay green
cargo fmt --check --manifest-path native/service/Cargo.toml   # in CI
cargo clippy --manifest-path native/service/Cargo.toml -- -D warnings
cargo test --manifest-path native/service/Cargo.toml
```

## Naming cheat-sheet

| Thing | Name |
| --- | --- |
| Service bus name | `com.lwb89dev.Astraea.Service` |
| Object path | `/com/lwb89dev/Astraea` |
| Calendar interface | `com.lwb89dev.Astraea.Calendar1` |
| Identity interface | `com.lwb89dev.NostrAccount1` |
| Desktop app id / desktop entry | `com.lwb89dev.Astraea` |
| systemd user unit | `astraea.service` |
| URL scheme | `astraea://` |

The app id and the service bus name are deliberately different: the GTK app
registers its own id on the bus for single-instance/deep-link behaviour.
