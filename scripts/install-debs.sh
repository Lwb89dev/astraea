#!/bin/sh
# Installs every built .deb with a single `apt install` call.
#
# The three packages are deliberately still separate (astraea-service /
# astraea-desktop / astraea-gnome-shell-extension) so a KDE/COSMIC user can
# install without the GNOME extension and each component can be upgraded on
# its own — see docs/packaging.md. This script is the one-command answer to
# "install everything, in the right order": `apt install` given several
# local .deb paths in one invocation resolves their Depends against each
# other and installs them in dependency order regardless of the order they
# were listed in (APT >= 1.1, i.e. every current Debian/Ubuntu/Pop!_OS).
# astraea-all is an empty metapackage that just expresses that grouping.
#
# Usage: ./scripts/install-debs.sh [--no-build] [--no-extension]
#   --no-build      reuse dist/*.deb instead of rebuilding
#   --no-extension  skip astraea-gnome-shell-extension (and astraea-all,
#                   which depends on it being available in the same
#                   transaction) — installs service + desktop only
#
# Requires root (apt); run it yourself, e.g. with sudo — this script does
# not escalate privileges on its own.
set -eu

here="$(cd "$(dirname "$0")/.." && pwd)"
build=1
with_extension=1

for arg in "$@"; do
    case "$arg" in
        --no-build) build=0 ;;
        --no-extension) with_extension=0 ;;
        *) echo "unknown option: $arg" >&2; exit 2 ;;
    esac
done

if [ "$build" = 1 ]; then
    "$here/scripts/build-deb.sh"
fi

version="$(sed -n 's/^version: *\([0-9][^+ ]*\).*/\1/p' "$here/pubspec.yaml" | head -n1)"
arch="$(dpkg --print-architecture)"
dist="$here/dist"

files="$dist/astraea-service_${version}_${arch}.deb"
[ -f "$dist/astraea-desktop_${version}_${arch}.deb" ] && \
    files="$files $dist/astraea-desktop_${version}_${arch}.deb"

if [ "$with_extension" = 1 ]; then
    [ -f "$dist/astraea-gnome-shell-extension_${version}_all.deb" ] && \
        files="$files $dist/astraea-gnome-shell-extension_${version}_all.deb"
    [ -f "$dist/astraea-all_${version}_all.deb" ] && \
        files="$files $dist/astraea-all_${version}_all.deb"
fi

for f in $files; do
    [ -f "$f" ] || { echo "missing: $f — build failed or version mismatch?" >&2; exit 1; }
done

echo "==> installing:"
for f in $files; do echo "    $(basename "$f")"; done

if [ "$(id -u)" = 0 ]; then
    # shellcheck disable=SC2086
    apt install -y $files
else
    echo "==> this needs root; re-run as:"
    echo "    sudo apt install -y $files"
    exit 1
fi
