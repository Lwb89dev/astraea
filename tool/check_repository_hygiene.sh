#!/usr/bin/env bash
set -euo pipefail

# This check is intentionally dependency-free so it can run locally and in CI.
# It catches common accidental commits; it does not replace reviewing staged
# changes or a dedicated secret scanner.

tracked_files="$(git ls-files)"

forbidden_paths="$({
  printf '%s\n' "$tracked_files" | grep -E '(^|/)(\.env($|\.)|local\.properties$|key\.properties$|google-services\.json$|GoogleService-Info\.plist$)' || true
  printf '%s\n' "$tracked_files" | grep -E '^\.[^/]+(/|$)' | grep -Ev '^(\.editorconfig|\.gitattributes|\.gitignore|\.metadata)$|^\.github/' || true
  printf '%s\n' "$tracked_files" | grep -E '(^|/)AGENTS\.md$' || true
  printf '%s\n' "$tracked_files" | grep -E '\.(jks|keystore|p12|pfx|pem|pk8|der|private-key|nsec|ics|ics\.json)$' || true
} | sort -u)"

if [[ -n "$forbidden_paths" ]]; then
  echo "Refusing tracked sensitive or local-only files:" >&2
  printf '%s\n' "$forbidden_paths" >&2
  exit 1
fi

secret_matches="$({
  git grep -I -nE 'AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|gh[pousr]_[0-9A-Za-z]{36,255}|xox[baprs]-[0-9A-Za-z-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|nsec1[023456789acdefghjklmnpqrstuvwxyz]{20,}' -- . \
    ':(exclude)test/fixtures/**' || true
})"

if [[ -n "$secret_matches" ]]; then
  echo "Possible credential material found in tracked files:" >&2
  printf '%s\n' "$secret_matches" >&2
  exit 1
fi

echo "Repository hygiene checks passed."
