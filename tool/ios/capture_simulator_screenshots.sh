#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_DIR="${1:-$ROOT_DIR/ios/app_store_screenshots}"
DEVICE_NAME="${SCREENSHOT_DEVICE:-iPhone 15 Pro Max}"
DEVICE_TAG="${SCREENSHOT_DEVICE_TAG:-}"
BUNDLE_ID="${SCREENSHOT_BUNDLE_ID:-com.codable.derbydash}"
SETTLE_SECONDS="${SCREENSHOT_SETTLE_SECONDS:-4}"

SCENARIOS=(
  home
  garage
  dashboard
  bracket
  history
  champion
  standings
)

mkdir -p "$OUTPUT_DIR"

if [[ -z "$DEVICE_TAG" ]]; then
  DEVICE_TAG="$(
    printf '%s' "$DEVICE_NAME" \
      | tr '[:upper:]' '[:lower:]' \
      | sed -E 's/[^a-z0-9]+/_/g; s/^_+//; s/_+$//'
  )"
fi

find_simulator_udid() {
  local device_name="$1"
  xcrun simctl list devices available \
    | awk -v name="$device_name" '
        index($0, name) {
          if (match($0, /[0-9A-F-]{36}/)) {
            print substr($0, RSTART, RLENGTH)
            exit
          }
        }
      '
}

SIMULATOR_UDID="$(find_simulator_udid "$DEVICE_NAME")"
if [[ -z "$SIMULATOR_UDID" ]]; then
  echo "Unable to find an available simulator named '$DEVICE_NAME'." >&2
  exit 1
fi

echo "Using simulator: $DEVICE_NAME ($SIMULATOR_UDID)"
open -a Simulator >/dev/null 2>&1 || true
xcrun simctl boot "$SIMULATOR_UDID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$SIMULATOR_UDID" -b

# Keep status bar consistent for App Store screenshots.
xcrun simctl status_bar "$SIMULATOR_UDID" override \
  --time 9:41 \
  --dataNetwork wifi \
  --wifiMode active \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4 \
  --batteryState charged \
  --batteryLevel 100

cleanup() {
  xcrun simctl status_bar "$SIMULATOR_UDID" clear >/dev/null 2>&1 || true
}
trap cleanup EXIT

for scenario in "${SCENARIOS[@]}"; do
  echo "Capturing scenario: $scenario"

  xcrun simctl terminate "$SIMULATOR_UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true

  (
    cd "$ROOT_DIR"
    flutter run \
      -d "$SIMULATOR_UDID" \
      --debug \
      --no-resident \
      --target lib/main_screenshot.dart \
      --dart-define SCREENSHOT_SCENARIO="$scenario"
  ) >/tmp/derby_dash_screenshot_"$scenario".log 2>&1

  sleep "$SETTLE_SECONDS"
  xcrun simctl io "$SIMULATOR_UDID" screenshot \
    "$OUTPUT_DIR/${scenario}_${DEVICE_TAG}.png"
done

echo "Screenshots saved to: $OUTPUT_DIR"
