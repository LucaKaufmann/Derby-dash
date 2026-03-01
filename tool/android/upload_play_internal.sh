#!/usr/bin/env bash
set -euo pipefail

# Load local env vars if present (kept out of git by .gitignore).
if [[ -f ".env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source ".env"
  set +a
fi

if [[ -z "${GOOGLE_PLAY_JSON_KEY_PATH:-}" ]]; then
  echo "GOOGLE_PLAY_JSON_KEY_PATH is required (path to Google Play service account JSON key)." >&2
  exit 1
fi

bundle exec fastlane android build_and_internal
