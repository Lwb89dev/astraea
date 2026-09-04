#!/bin/sh
# Verifies that every versioned artifact agrees with pubspec.yaml (the
# owner of the version number — docs/release-process.md). CI runs this.
set -eu

here="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

want="$(sed -n 's/^version: *\([0-9][^+ ]*\).*/\1/p' "$here/pubspec.yaml" | head -n1)"
[ -n "$want" ] || { echo "cannot read version from pubspec.yaml" >&2; exit 1; }
echo "pubspec.yaml: $want"

check() {
    label="$1"; got="$2"
    if [ "$got" = "$want" ]; then
        echo "OK   $label: $got"
    else
        echo "FAIL $label: '$got' (want $want)" >&2
        fail=1
    fi
}

check "native/service/Cargo.toml" \
    "$(sed -n 's/^version = "\(.*\)"/\1/p' "$here/native/service/Cargo.toml" | head -n1)"

check "native/cosmic-applet/Cargo.toml" \
    "$(sed -n 's/^version = "\(.*\)"/\1/p' "$here/native/cosmic-applet/Cargo.toml" | head -n1)"

check "AppStream newest release" \
    "$(sed -n 's/.*<release version="\([^"]*\)".*/\1/p' \
        "$here/assets/appstream/com.lwb89dev.Astraea.metainfo.xml" | head -n1)"

check "packaging/rpm/astraea.spec" \
    "$(sed -n 's/^Version: *//p' "$here/packaging/rpm/astraea.spec" | head -n1)"

check "packaging/arch/PKGBUILD" \
    "$(sed -n 's/^pkgver=//p' "$here/packaging/arch/PKGBUILD" | head -n1)"

# The GNOME extension is versioned by extensions.gnome.org — no number in
# metadata.json by design; just make sure nobody added a stray one.
if grep -q '"version"' "$here/extensions/gnome/astraea@lwb89dev/metadata.json"; then
    echo "FAIL extension metadata.json must not pin a version" >&2
    fail=1
else
    echo "OK   extension metadata.json: unversioned (by design)"
fi

[ "$fail" = 0 ] && echo "versions consistent" || exit 1
