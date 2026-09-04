#!/bin/sh
# Validates packaging artifacts with whatever validators the machine has.
# Structural checks always run; lintian/rpmlint run when installed. The
# distro install/uninstall matrix (Ubuntu/Debian/Fedora/openSUSE/Arch in
# containers) is documented in docs/packaging.md — this script is the fast
# local subset of it.
set -eu

here="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
note() { echo "==> $*"; }
bad() { echo "FAIL: $*" >&2; fail=1; }

note "desktop entry"
desktop-file-validate "$here/assets/desktop/com.lwb89dev.Astraea.desktop" \
    || bad "desktop entry invalid"

note "AppStream metainfo (screenshot placeholder warning is accepted)"
if command -v appstreamcli >/dev/null 2>&1; then
    appstreamcli validate --no-net "$here/assets/appstream/com.lwb89dev.Astraea.metainfo.xml" \
        || bad "metainfo invalid"
fi

note "GNOME extension metadata"
python3 -c "
import json, sys
m = json.load(open('$here/extensions/gnome/astraea@lwb89dev/metadata.json'))
assert m['uuid'] == 'astraea@lwb89dev', 'uuid'
assert m['shell-version'], 'shell-version'
" || bad "extension metadata invalid"

note "shell scripts parse"
for s in "$here"/scripts/*.sh "$here"/packaging/common/install.sh \
         "$here"/packaging/deb/postinst-* "$here"/packaging/deb/postrm-*; do
    sh -n "$s" || bad "syntax: $s"
done

if ls "$here"/dist/*.deb >/dev/null 2>&1; then
    for deb in "$here"/dist/*.deb; do
        note "deb: $(basename "$deb")"
        dpkg-deb --info "$deb" >/dev/null || bad "unreadable: $deb"
        dpkg-deb --contents "$deb" | awk '{print $6}' | grep -qv '^\./usr\|^\./$' \
            && bad "$deb writes outside /usr" || true
        if command -v lintian >/dev/null 2>&1; then
            lintian --no-tag-display-limit "$deb" || true
        fi
    done
else
    note "no .deb in dist/ (run scripts/build-deb.sh) — skipping"
fi

if ls "$here"/dist/*.rpm >/dev/null 2>&1 && command -v rpmlint >/dev/null 2>&1; then
    rpmlint "$here"/dist/*.rpm || true
fi

[ "$fail" = 0 ] && echo "package validation OK" || exit 1
