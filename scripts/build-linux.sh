#!/bin/sh
# Builds the Linux artifacts and stages them into dist/stage/ with the final
# filesystem layout (/usr prefix). Every package format (deb, rpm, tarball,
# flatpak) starts from this staged tree, so the layout is defined once.
#
# Usage: ./scripts/build-linux.sh [--skip-flutter] [--skip-service] [--debug]
#   --skip-flutter   stage only the service + extension (no GUI)
#   --skip-service   stage only the GUI + extension (no daemon)
#   --debug          use debug builds
set -eu

here="$(cd "$(dirname "$0")/.." && pwd)"
stage="$here/dist/stage"
app_id="com.lwb89dev.Astraea"

skip_flutter=0
skip_service=0
profile=release
for arg in "$@"; do
    case "$arg" in
        --skip-flutter) skip_flutter=1 ;;
        --skip-service) skip_service=1 ;;
        --debug) profile=debug ;;
        *) echo "unknown option: $arg" >&2; exit 2 ;;
    esac
done

version="$(sed -n 's/^version: *\([0-9][^+ ]*\).*/\1/p' "$here/pubspec.yaml" | head -n1)"
[ -n "$version" ] || { echo "could not read version from pubspec.yaml" >&2; exit 1; }

echo "==> staging astraea $version into $stage"
rm -rf "$stage"
mkdir -p "$stage"

# --- background service -------------------------------------------------
if [ "$skip_service" = 0 ]; then
    echo "==> cargo build ($profile)"
    if [ "$profile" = release ]; then
        cargo build --manifest-path "$here/native/service/Cargo.toml" --release
    else
        cargo build --manifest-path "$here/native/service/Cargo.toml"
    fi
    install -Dm0755 "$here/native/service/target/$profile/astraea-service" \
        "$stage/usr/libexec/astraea/astraea-service"

    install -Dm0644 /dev/stdin "$stage/usr/lib/systemd/user/astraea.service" \
        < "$here/packaging/common/astraea.service"
    sed -i 's|@LIBEXECDIR@|/usr/libexec|g' "$stage/usr/lib/systemd/user/astraea.service"

    install -Dm0644 /dev/stdin \
        "$stage/usr/share/dbus-1/services/$app_id.Service.service" \
        < "$here/packaging/common/$app_id.Service.service"
    sed -i 's|@LIBEXECDIR@|/usr/libexec|g' \
        "$stage/usr/share/dbus-1/services/$app_id.Service.service"
fi

# --- Flutter desktop app ------------------------------------------------
if [ "$skip_flutter" = 0 ]; then
    echo "==> flutter build linux ($profile)"
    if [ "$profile" = release ]; then
        (cd "$here" && flutter build linux --release)
        bundle="$here/build/linux/x64/release/bundle"
    else
        (cd "$here" && flutter build linux --debug)
        bundle="$here/build/linux/x64/debug/bundle"
    fi
    mkdir -p "$stage/usr/lib/astraea"
    cp -a "$bundle/." "$stage/usr/lib/astraea/"
    mkdir -p "$stage/usr/bin"
    ln -sf ../lib/astraea/astraea "$stage/usr/bin/astraea"

    install -Dm0644 "$here/assets/desktop/$app_id.desktop" \
        "$stage/usr/share/applications/$app_id.desktop"
    install -Dm0644 "$here/assets/appstream/$app_id.metainfo.xml" \
        "$stage/usr/share/metainfo/$app_id.metainfo.xml"

    echo "==> generating hicolor icons"
    for size in 512 256 128 64 48 32; do
        out="$stage/usr/share/icons/hicolor/${size}x${size}/apps/$app_id.png"
        mkdir -p "$(dirname "$out")"
        convert "$here/assets/icon/icon.png" -resize "${size}x${size}" "$out"
    done
fi

# --- GNOME Shell extension ---------------------------------------------
ext_dir="$stage/usr/share/gnome-shell/extensions/astraea@lwb89dev"
mkdir -p "$ext_dir"
cp -a "$here/extensions/gnome/astraea@lwb89dev/." "$ext_dir/"

# --- docs ---------------------------------------------------------------
install -Dm0644 "$here/README.md" "$stage/usr/share/doc/astraea/README.md"
install -Dm0644 "$here/docs/linux-architecture.md" \
    "$stage/usr/share/doc/astraea/linux-architecture.md"

echo "==> staged:"
(cd "$stage" && find . -type f -o -type l | sort | head -40)
echo "    version: $version"
