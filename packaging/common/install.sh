#!/bin/sh
# Astraea tarball installer. Ships inside the release tarball next to usr/.
#
# Usage: ./install.sh [--prefix DIR] [--user] [--dry-run]
#        ./install.sh --uninstall [--dry-run]
#
#   --prefix DIR  install under DIR (default /usr/local, needs root)
#   --user        install under ~/.local (no root; also wires systemd user
#                 + D-Bus activation into the XDG data dir)
#   --dry-run     print every action without touching the filesystem
#   --uninstall   remove exactly the files a previous run recorded in the
#                 manifest (never touches user data in ~/.local/share/astraea)
set -eu

here="$(cd "$(dirname "$0")" && pwd)"
prefix=/usr/local
user_mode=0
dry=0
uninstall=0

while [ $# -gt 0 ]; do
    case "$1" in
        --prefix) prefix="$2"; shift ;;
        --user) user_mode=1; prefix="$HOME/.local" ;;
        --dry-run) dry=1 ;;
        --uninstall) uninstall=1 ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done

manifest_dir="${XDG_STATE_HOME:-$HOME/.local/state}/astraea"
manifest="$manifest_dir/install-manifest.txt"

run() {
    if [ "$dry" = 1 ]; then echo "DRY: $*"; else "$@"; fi
}

if [ "$uninstall" = 1 ]; then
    [ -f "$manifest" ] || { echo "no manifest at $manifest — nothing to uninstall"; exit 0; }
    while IFS= read -r f; do
        [ -n "$f" ] && run rm -f "$f"
    done < "$manifest"
    run rm -f "$manifest"
    echo "uninstalled (user data in \${XDG_DATA_HOME:-~/.local/share}/astraea is kept)"
    exit 0
fi

[ -d "$here/usr" ] || { echo "usr/ not found next to install.sh" >&2; exit 1; }

record() {
    if [ "$dry" = 0 ]; then
        mkdir -p "$manifest_dir"
        echo "$1" >> "$manifest"
    fi
}

echo "installing to $prefix (dry-run: $dry)"
[ "$dry" = 0 ] && : > "$manifest" 2>/dev/null || true

(cd "$here/usr" && find . -type f -o -type l) | while IFS= read -r rel; do
    rel="${rel#./}"
    case "$rel" in
        # systemd + dbus need XDG paths in user mode, handled below.
        lib/systemd/user/*|share/dbus-1/services/*) [ "$user_mode" = 1 ] && continue ;;
    esac
    dest="$prefix/$rel"
    run mkdir -p "$(dirname "$dest")"
    run cp -a "$here/usr/$rel" "$dest"
    record "$dest"
done

# Fix the libexec path baked into unit + activation files.
fix_paths() {
    target="$1"
    [ -f "$target" ] || return 0
    run sed -i "s|/usr/libexec|$prefix/libexec|g" "$target"
}

if [ "$user_mode" = 1 ]; then
    data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    for pair in \
        "lib/systemd/user/astraea.service:$data_home/systemd/user/astraea.service" \
        "share/dbus-1/services/com.lwb89dev.Astraea.Service.service:$data_home/dbus-1/services/com.lwb89dev.Astraea.Service.service"
    do
        src="$here/usr/${pair%%:*}"; dest="${pair#*:}"
        [ -f "$src" ] || continue
        run mkdir -p "$(dirname "$dest")"
        run cp "$src" "$dest"
        fix_paths "$dest"
        record "$dest"
    done
    command -v systemctl >/dev/null 2>&1 && run systemctl --user daemon-reload || true
else
    fix_paths "$prefix/lib/systemd/user/astraea.service"
    fix_paths "$prefix/share/dbus-1/services/com.lwb89dev.Astraea.Service.service"
fi

command -v update-desktop-database >/dev/null 2>&1 && \
    run update-desktop-database -q "$prefix/share/applications" || true

echo "done. Manifest: $manifest"
