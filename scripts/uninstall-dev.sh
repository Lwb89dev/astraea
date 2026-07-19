#!/bin/sh
# Removes everything scripts/install-dev.sh installed. User data in
# ~/.local/share/astraea (database) is intentionally NOT touched.
set -eu

data_home="${XDG_DATA_HOME:-$HOME/.local/share}"

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user stop astraea.service 2>/dev/null || true
fi

rm -f "$data_home/systemd/user/astraea.service"
rm -f "$data_home/dbus-1/services/com.lwb89dev.Astraea.Service.service"
rm -f "$data_home/applications/com.lwb89dev.Astraea.desktop"
rm -f "$data_home/icons/hicolor/512x512/apps/com.lwb89dev.Astraea.png"
rm -f "$HOME/.local/libexec/astraea/astraea-service"
rmdir "$HOME/.local/libexec/astraea" 2>/dev/null || true

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user daemon-reload 2>/dev/null || true
fi
command -v update-desktop-database >/dev/null 2>&1 && \
    update-desktop-database "$data_home/applications" 2>/dev/null || true

echo "uninstalled (user data in $data_home/astraea was kept)"
