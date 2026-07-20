#!/bin/sh
# Optional AppImage of the DESKTOP APP ONLY (standalone GUI).
#
# Deliberate limitation (docs/packaging.md): an AppImage cannot install the
# D-Bus activation file, the systemd user unit or the GNOME extension, so
# shell integration and on-demand service start require a native package or
# the tarball installer. The AppImage is for trying the GUI: it shows the
# service-unreachable recovery screen when astraea-service is absent.
#
# Requires appimagetool on PATH: https://github.com/AppImage/appimagetool
set -eu

here="$(cd "$(dirname "$0")/.." && pwd)"
stage="$here/dist/stage"

command -v appimagetool >/dev/null 2>&1 || {
    echo "appimagetool not found — see the header of this script" >&2
    exit 1
}

[ "${1:-}" = "--no-build" ] || "$here/scripts/build-linux.sh" --skip-service
[ -d "$stage/usr/lib/astraea" ] || { echo "no flutter bundle staged" >&2; exit 1; }

version="$(sed -n 's/^version: *\([0-9][^+ ]*\).*/\1/p' "$here/pubspec.yaml" | head -n1)"
appdir="$here/dist/Astraea.AppDir"
rm -rf "$appdir"
mkdir -p "$appdir/usr"
cp -a "$stage/usr/lib" "$appdir/usr/"
install -Dm0644 "$here/assets/desktop/com.lwb89dev.Astraea.desktop" \
    "$appdir/com.lwb89dev.Astraea.desktop"
install -Dm0644 "$stage/usr/share/icons/hicolor/512x512/apps/com.lwb89dev.Astraea.png" \
    "$appdir/com.lwb89dev.Astraea.png"
cat > "$appdir/AppRun" <<'EOF'
#!/bin/sh
here="$(dirname "$(readlink -f "$0")")"
exec "$here/usr/lib/astraea/astraea" "$@"
EOF
chmod +x "$appdir/AppRun"

ARCH="$(uname -m)" appimagetool "$appdir" "$here/dist/Astraea-$version-$(uname -m).AppImage"
echo "built dist/Astraea-$version-$(uname -m).AppImage"
