#!/bin/sh
# Builds the modular Debian packages (astraea-service, astraea-desktop,
# astraea-gnome-shell-extension) from the staged tree in dist/stage/.
# Run ./scripts/build-linux.sh first (or let this script do it).
#
# Usage: ./scripts/build-deb.sh [--no-build]
set -eu

here="$(cd "$(dirname "$0")/.." && pwd)"
stage="$here/dist/stage"
out="$here/dist"

[ "${1:-}" = "--no-build" ] || "$here/scripts/build-linux.sh"
[ -d "$stage/usr" ] || { echo "dist/stage is empty — run scripts/build-linux.sh" >&2; exit 1; }

version="$(sed -n 's/^version: *\([0-9][^+ ]*\).*/\1/p' "$here/pubspec.yaml" | head -n1)"
arch="$(dpkg --print-architecture)"

# copy_tree PKGROOT PATH...: moves the listed staged paths into a package root.
copy_tree() {
    pkgroot="$1"; shift
    for path in "$@"; do
        [ -e "$stage/$path" ] || continue
        mkdir -p "$pkgroot/$(dirname "$path")"
        cp -a "$stage/$path" "$pkgroot/$(dirname "$path")/"
    done
}

build_pkg() {
    name="$1"; control="$2"; pkg_arch="$3"
    pkgroot="$here/dist/deb/$name"
    mkdir -p "$pkgroot/DEBIAN"
    sed -e "s/@VERSION@/$version/g" -e "s/@ARCH@/$pkg_arch/g" \
        "$here/packaging/deb/$control" > "$pkgroot/DEBIAN/control"
    if [ -f "$here/packaging/deb/postinst-${name#astraea-}" ]; then
        install -m 0755 "$here/packaging/deb/postinst-${name#astraea-}" "$pkgroot/DEBIAN/postinst"
    fi
    if [ -f "$here/packaging/deb/postrm-${name#astraea-}" ]; then
        install -m 0755 "$here/packaging/deb/postrm-${name#astraea-}" "$pkgroot/DEBIAN/postrm"
    fi
    dpkg-deb --build --root-owner-group "$pkgroot" \
        "$out/${name}_${version}_${pkg_arch}.deb" >/dev/null
    echo "built $out/${name}_${version}_${pkg_arch}.deb"
}

rm -rf "$here/dist/deb"

# astraea-service ---------------------------------------------------------
pkgroot="$here/dist/deb/astraea-service"
copy_tree "$pkgroot" \
    usr/libexec/astraea \
    usr/lib/systemd/user/astraea.service \
    usr/share/dbus-1/services/com.lwb89dev.Astraea.Service.service \
    usr/share/doc/astraea
build_pkg astraea-service control-service "$arch"

# astraea-desktop ---------------------------------------------------------
if [ -d "$stage/usr/lib/astraea" ]; then
    pkgroot="$here/dist/deb/astraea-desktop"
    copy_tree "$pkgroot" \
        usr/bin/astraea \
        usr/lib/astraea \
        usr/share/applications \
        usr/share/metainfo \
        usr/share/icons
    build_pkg astraea-desktop control-desktop "$arch"
else
    echo "skipping astraea-desktop (no flutter bundle staged)"
fi

# astraea-gnome-shell-extension ------------------------------------------
pkgroot="$here/dist/deb/astraea-gnome-shell-extension"
copy_tree "$pkgroot" usr/share/gnome-shell
build_pkg astraea-gnome-shell-extension control-gnome-extension all
