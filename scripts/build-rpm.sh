#!/bin/sh
# Packs dist/stage into Source0 and runs rpmbuild against
# packaging/rpm/astraea.spec. Requires rpmbuild (rpm-build / rpmdevtools).
#
# Usage: ./scripts/build-rpm.sh [--no-build]
set -eu

here="$(cd "$(dirname "$0")/.." && pwd)"
stage="$here/dist/stage"

command -v rpmbuild >/dev/null 2>&1 || {
    echo "rpmbuild not found — install rpm-build (Fedora) / rpm (Debian) first" >&2
    exit 1
}

[ "${1:-}" = "--no-build" ] || "$here/scripts/build-linux.sh"
[ -d "$stage/usr" ] || { echo "dist/stage is empty — run scripts/build-linux.sh" >&2; exit 1; }

version="$(sed -n 's/^version: *\([0-9][^+ ]*\).*/\1/p' "$here/pubspec.yaml" | head -n1)"
topdir="$here/dist/rpm"
mkdir -p "$topdir/SOURCES" "$topdir/SPECS"

tar -C "$stage" -czf "$topdir/SOURCES/astraea-stage-$version.tar.gz" usr
cp "$here/packaging/rpm/astraea.spec" "$topdir/SPECS/"

rpmbuild -bb \
    --define "_topdir $topdir" \
    --define "version $version" \
    "$topdir/SPECS/astraea.spec"

find "$topdir/RPMS" -name '*.rpm' -exec cp {} "$here/dist/" \;
echo "RPMs copied to dist/"

if command -v rpmlint >/dev/null 2>&1; then
    rpmlint "$here"/dist/*.rpm || true
fi
