#!/bin/sh
# Developer install: builds astraea-service and wires it into the current
# user session (no root, no system paths). Undo with uninstall-dev.sh.
#
# Usage: ./scripts/install-dev.sh [--debug]
set -eu

here="$(cd "$(dirname "$0")/.." && pwd)"
profile=release
cargo_flag=--release
if [ "${1:-}" = "--debug" ]; then
    profile=debug
    cargo_flag=""
fi

data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
libexec_dir="$HOME/.local/libexec/astraea"
unit_dir="$data_home/systemd/user"
dbus_dir="$data_home/dbus-1/services"
apps_dir="$data_home/applications"
icons_dir="$data_home/icons/hicolor"

echo "==> building astraea-service ($profile)"
# shellcheck disable=SC2086
cargo build --manifest-path "$here/native/service/Cargo.toml" $cargo_flag

echo "==> installing binary to $libexec_dir"
mkdir -p "$libexec_dir"
install -m 0755 "$here/native/service/target/$profile/astraea-service" "$libexec_dir/astraea-service"

echo "==> installing systemd user unit + D-Bus activation"
mkdir -p "$unit_dir" "$dbus_dir"
sed "s|@LIBEXECDIR@|$HOME/.local/libexec|g" \
    "$here/packaging/common/astraea.service" > "$unit_dir/astraea.service"
sed "s|@LIBEXECDIR@|$HOME/.local/libexec|g" \
    "$here/packaging/common/com.lwb89dev.Astraea.Service.service" > "$dbus_dir/com.lwb89dev.Astraea.Service.service"

if [ -f "$here/assets/desktop/com.lwb89dev.Astraea.desktop" ]; then
    echo "==> installing desktop entry"
    mkdir -p "$apps_dir"
    # Dev build: point Exec at the flutter bundle if present, else leave the
    # packaged name and let PATH resolve it.
    install -m 0644 "$here/assets/desktop/com.lwb89dev.Astraea.desktop" \
        "$apps_dir/com.lwb89dev.Astraea.desktop"
    command -v update-desktop-database >/dev/null 2>&1 && \
        update-desktop-database "$apps_dir" || true
fi

if [ -f "$here/assets/icon/icon.png" ]; then
    mkdir -p "$icons_dir/512x512/apps"
    install -m 0644 "$here/assets/icon/icon.png" \
        "$icons_dir/512x512/apps/com.lwb89dev.Astraea.png"
fi

# is-system-running exits non-zero for "degraded" too, so probe with
# daemon-reload itself: it only works when a user manager is reachable.
if command -v systemctl >/dev/null 2>&1 && systemctl --user daemon-reload 2>/dev/null; then
    echo "==> systemd user daemon reloaded"
else
    echo "==> no reachable systemd user manager; the session D-Bus daemon"
    echo "    will spawn the service directly from the activation file."
fi

echo
echo "done. Try:"
echo "  busctl --user call com.lwb89dev.Astraea.Service /com/lwb89dev/Astraea \\"
echo "    com.lwb89dev.Astraea.Calendar1 GetVersion"
echo "  $libexec_dir/astraea-service status"
echo "  journalctl --user -u astraea.service -f"
