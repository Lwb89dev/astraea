#!/bin/sh
# Builds the relocatable release tarball from dist/stage: usr/ + install.sh.
#
# Usage: ./scripts/build-tarball.sh [--no-build]
set -eu

here="$(cd "$(dirname "$0")/.." && pwd)"
stage="$here/dist/stage"

[ "${1:-}" = "--no-build" ] || "$here/scripts/build-linux.sh"
[ -d "$stage/usr" ] || { echo "dist/stage is empty — run scripts/build-linux.sh" >&2; exit 1; }

version="$(sed -n 's/^version: *\([0-9][^+ ]*\).*/\1/p' "$here/pubspec.yaml" | head -n1)"
arch="$(uname -m)"
name="astraea-$version-linux-$arch"
workdir="$here/dist/$name"

rm -rf "$workdir"
mkdir -p "$workdir"
cp -a "$stage/usr" "$workdir/"
install -m 0755 "$here/packaging/common/install.sh" "$workdir/install.sh"

tar -C "$here/dist" -czf "$here/dist/$name.tar.gz" "$name"
rm -rf "$workdir"
(cd "$here/dist" && sha256sum "$name.tar.gz" > "$name.tar.gz.sha256")
echo "built dist/$name.tar.gz (+ .sha256)"
