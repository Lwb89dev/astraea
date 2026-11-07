#!/bin/sh
# Downloads Astraea's Linux .deb packages from a GitHub release and installs
# them with a single `apt install` call — for people who don't want to
# clone and build from source (see build-deb.sh / install-debs.sh for that
# path instead).
#
# Interactive by design: shows exactly what it downloaded and is about to
# install, and — if it isn't already root — explains why it needs sudo and
# asks before running it. It never re-execs itself as root silently.
#
# Checksum verification: if the release also published a SHA256SUMS asset,
# every downloaded .deb is verified against it before anything is installed.
# Older releases that predate this convention just get a clear warning
# instead of a hard failure.
#
# Usage: ./scripts/install-release.sh [--tag TAG] [--no-extension] [--yes]
#   --tag TAG        install a specific release instead of the latest
#   --no-extension   skip astraea-gnome-shell-extension (and astraea-all,
#                     which recommends it) for KDE/COSMIC installs
#   --yes            skip the download/checksum confirmation prompts;
#                     the sudo prompt is still asked explicitly
set -eu

repo="Lwb89dev/astraea"
tag=""
with_extension=1
assume_yes=0

while [ $# -gt 0 ]; do
    case "$1" in
        --tag) tag="${2:?--tag needs a value}"; shift 2 ;;
        --no-extension) with_extension=0; shift ;;
        --yes) assume_yes=1; shift ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
done

command -v curl >/dev/null 2>&1 || { echo "curl is required" >&2; exit 1; }
command -v dpkg >/dev/null 2>&1 || { echo "this installer is for Debian-family systems (apt/dpkg)" >&2; exit 1; }

# Reads a yes/no answer even when stdin isn't a terminal (e.g. this script
# was piped from curl) by falling back to /dev/tty; with no terminal at all
# (CI, `--yes` not passed) the safe answer is always "no".
confirm() {
    prompt="$1"
    default="$2" # "y" or "n"
    reply=""
    if [ -t 0 ]; then
        printf '%s' "$prompt"
        read -r reply 2>/dev/null || reply=""
    elif [ -e /dev/tty ]; then
        # Grouped so a failure in either half (no controlling terminal,
        # e.g. some CI/container setups) can't leave $reply unset under
        # `set -u` — it falls back to $default instead of aborting the
        # script with an unrelated "parameter not set" error.
        { printf '%s' "$prompt" > /dev/tty; read -r reply < /dev/tty; } 2>/dev/null || reply=""
    fi
    case "$reply" in
        "") [ "$default" = y ] ;;
        y|Y|yes|YES) true ;;
        *) false ;;
    esac
}

api="https://api.github.com/repos/$repo/releases"
if [ -n "$tag" ]; then
    api="$api/tags/$tag"
else
    api="$api/latest"
fi

echo "==> looking up the release..."
release_json="$(curl -fsSL -H 'Accept: application/vnd.github+json' "$api")" || {
    echo "could not reach GitHub, or no such release" >&2
    exit 1
}

release_tag="$(printf '%s' "$release_json" | sed -n 's/^ *"tag_name": *"\(.*\)",\{0,1\}$/\1/p' | head -n1)"
[ -n "$release_tag" ] || { echo "could not parse the release metadata" >&2; exit 1; }
echo "==> release: $release_tag"

# GitHub pretty-prints one field per line, so this is a plain field
# extraction, not a JSON parser — good enough for a fixed API shape and
# keeps this script dependency-free (no jq required).
asset_urls="$(printf '%s' "$release_json" | sed -n 's/^ *"browser_download_url": *"\(.*\)",\{0,1\}$/\1/p')"

arch="$(dpkg --print-architecture)"
deb_urls="$(printf '%s' "$asset_urls" | grep -E "_(${arch}|all)\.deb\$" || true)"
[ -n "$deb_urls" ] || { echo "release $release_tag has no .deb assets for $arch" >&2; exit 1; }

if [ "$with_extension" = 0 ]; then
    deb_urls="$(printf '%s' "$deb_urls" | grep -v -e 'gnome-shell-extension' -e 'astraea-all_')"
fi

sums_url="$(printf '%s' "$asset_urls" | grep '/SHA256SUMS$' || true)"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
# mktemp -d defaults to 0700, which apt's sandboxed download helper (the
# unprivileged _apt user) can't traverse when we later `sudo apt install`
# straight from here — apt falls back to an unsandboxed read with a
# warning, but there's no reason to trigger that: these are public
# packages we just downloaded over HTTPS, nothing sensitive lives here.
chmod 755 "$work"

echo "==> downloading:"
files=""
for url in $deb_urls; do
    name="$(basename "$url")"
    echo "    $name"
    curl -fsSL -o "$work/$name" "$url"
    files="$files $work/$name"
done

if [ -n "$sums_url" ]; then
    curl -fsSL -o "$work/SHA256SUMS" "$sums_url"
    echo "==> verifying checksums..."
    : > "$work/SHA256SUMS.filtered"
    for f in $files; do
        name="$(basename "$f")"
        if ! grep -F " $name" "$work/SHA256SUMS" >> "$work/SHA256SUMS.filtered"; then
            echo "no checksum entry for $name in SHA256SUMS — aborting" >&2
            exit 1
        fi
    done
    if ! (cd "$work" && sha256sum -c SHA256SUMS.filtered); then
        echo "checksum verification FAILED — not installing anything" >&2
        exit 1
    fi
    echo "    OK"
else
    echo "==> warning: release $release_tag has no SHA256SUMS asset — downloads"
    echo "    could not be verified against a published checksum."
    if [ "$assume_yes" = 0 ] && ! confirm "    continue anyway? [y/N] " n; then
        echo "aborted."
        exit 1
    fi
fi

echo
echo "==> about to install:"
for f in $files; do echo "    $(basename "$f")"; done
echo

if [ "$assume_yes" = 0 ] && ! confirm "install now? [Y/n] " y; then
    echo "aborted."
    exit 1
fi

if [ "$(id -u)" = 0 ]; then
    # shellcheck disable=SC2086
    apt install -y $files
    exit 0
fi

echo
echo "installing needs root, to run: apt install <the .deb files above>"
# Deliberately ignores --yes: the whole point of this prompt is that sudo
# is never reached for without asking, no matter how the script was invoked.
if confirm "run that with sudo now? [y/N] " n; then
    # shellcheck disable=SC2086
    sudo apt install -y $files
else
    echo "==> not installing. Run it yourself with:"
    echo "    sudo apt install -y$files"
    exit 1
fi
