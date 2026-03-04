#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_DIR="${1:-$ROOT_DIR/android/play_store_screenshots}"
BUNDLE_ID="${ANDROID_SCREENSHOT_BUNDLE_ID:-com.codable.derbydash}"
SETTLE_SECONDS="${ANDROID_SCREENSHOT_SETTLE_SECONDS:-4}"
DEVICES_FILE="${ANDROID_SCREENSHOT_DEVICES_FILE:-$ROOT_DIR/tool/android/screenshot_devices.json}"
SCENARIOS_CSV="${ANDROID_SCREENSHOT_SCENARIOS:-home,garage,dashboard,bracket,history,champion,standings}"
LOCALE="${ANDROID_SCREENSHOT_LOCALE:-en-US}"
SKIP_BUILD="${ANDROID_SCREENSHOT_SKIP_BUILD:-0}"
PARALLEL_DEVICES="${ANDROID_SCREENSHOT_PARALLEL_DEVICES:-0}"
EMULATOR_ARGS_RAW="${ANDROID_SCREENSHOT_EMULATOR_ARGS:--no-snapshot -no-boot-anim -noaudio -netfast -gpu swiftshader_indirect}"
LOGS_DIR="$OUTPUT_DIR/logs"

VALID_SCENARIOS=(
  home
  garage
  dashboard
  bracket
  history
  champion
  standings
)

read -r -a EMULATOR_ARGS <<<"$EMULATOR_ARGS_RAW"

capture_screenshot() {
  local serial="$1"
  local scenario="$2"
  local destination_path="$3"
  local remote_path="/sdcard/derby_dash_${scenario}.png"

  adb -s "$serial" shell screencap -p "$remote_path" >/dev/null
  adb -s "$serial" pull "$remote_path" "$destination_path" >/dev/null
  adb -s "$serial" shell rm -f "$remote_path" >/dev/null 2>&1 || true
}

log() {
  printf '[android-shots] %s\n' "$*"
}

warn() {
  printf '[android-shots] WARNING: %s\n' "$*" >&2
}

error() {
  printf '[android-shots] ERROR: %s\n' "$*" >&2
}

require_command() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    error "Missing required command: $name"
    exit 1
  fi
}

find_serial_for_avd() {
  local avd_name="$1"
  local serial
  while IFS= read -r serial; do
    reported_avd="$(adb -s "$serial" emu avd name 2>/dev/null | tr -d '\r' | awk 'NF && $0 != "OK" { print; exit }')"
    if [[ "$reported_avd" == "$avd_name" ]]; then
      printf '%s\n' "$serial"
      return 0
    fi
  done < <(adb devices | awk '/^emulator-[0-9]+\tdevice$/{print $1}')
  return 1
}

wait_for_boot() {
  local serial="$1"
  local timeout_seconds="${2:-300}"
  local elapsed=0

  adb -s "$serial" wait-for-device >/dev/null
  while [[ "$elapsed" -lt "$timeout_seconds" ]]; do
    boot_completed="$(adb -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
    if [[ "$boot_completed" == "1" ]]; then
      return 0
    fi
    sleep 2
    elapsed=$((elapsed + 2))
  done

  return 1
}

disable_animations() {
  local serial="$1"
  adb -s "$serial" shell settings put global window_animation_scale 0 >/dev/null 2>&1 || true
  adb -s "$serial" shell settings put global transition_animation_scale 0 >/dev/null 2>&1 || true
  adb -s "$serial" shell settings put global animator_duration_scale 0 >/dev/null 2>&1 || true
}

join_by() {
  local delimiter="$1"
  shift
  local first="$1"
  shift
  printf '%s' "$first"
  for value in "$@"; do
    printf '%s%s' "$delimiter" "$value"
  done
}

handle_device_failure() {
  local required="$1"
  local message="$2"
  if [[ "$required" == "true" ]]; then
    error "$message"
    return 1
  fi
  warn "$message (optional device, continuing)"
  return 0
}

run_device_capture() {
  local device_row="$1"

  local device_id avd_name tag output_subdir required
  device_id="$(jq -r '.id' <<<"$device_row")"
  avd_name="$(jq -r '.avd_name' <<<"$device_row")"
  tag="$(jq -r '.tag' <<<"$device_row")"
  output_subdir="$(jq -r '.output_subdir' <<<"$device_row")"
  required="$(jq -r '.required' <<<"$device_row")"

  local serial=""
  local started_by_script=0
  local emulator_log="$LOGS_DIR/${device_id}_emulator.log"

  cleanup_device() {
    if [[ "$started_by_script" -eq 1 && -n "$serial" ]]; then
      adb -s "$serial" emu kill >/dev/null 2>&1 || true
    fi
  }
  trap cleanup_device RETURN

  mkdir -p "$OUTPUT_DIR/$output_subdir"
  log "Preparing device '$device_id' using AVD '$avd_name'"

  if existing_serial="$(find_serial_for_avd "$avd_name" 2>/dev/null)"; then
    serial="$existing_serial"
    log "Using running emulator $serial for AVD '$avd_name'"
  else
    log "Starting emulator for AVD '$avd_name'"
    emulator -avd "$avd_name" "${EMULATOR_ARGS[@]}" >"$emulator_log" 2>&1 </dev/null &
    started_by_script=1

    local attempts=0
    while [[ "$attempts" -lt 90 ]]; do
      if serial="$(find_serial_for_avd "$avd_name" 2>/dev/null)"; then
        break
      fi
      sleep 2
      attempts=$((attempts + 1))
    done
  fi

  if [[ -z "$serial" ]]; then
    handle_device_failure "$required" "Unable to detect emulator serial for AVD '$avd_name'" || return 1
    return 0
  fi

  if ! wait_for_boot "$serial" 300; then
    adb devices -l >&2 || true
    adb -s "$serial" shell getprop >&2 || true
    handle_device_failure "$required" "Emulator '$serial' did not boot in time for AVD '$avd_name'" || return 1
    return 0
  fi

  disable_animations "$serial"
  adb -s "$serial" shell pm clear "$BUNDLE_ID" >/dev/null 2>&1 || true

  if [[ "$LOCALE" != "en-US" ]]; then
    warn "ANDROID_SCREENSHOT_LOCALE=$LOCALE requested, but this pipeline is currently optimized for en-US."
  fi

  local scenario
  for scenario in "${SCENARIOS[@]}"; do
    local scenario_log="$LOGS_DIR/${device_id}_${scenario}.log"
    local screenshot_path="$OUTPUT_DIR/$output_subdir/${scenario}_${tag}.png"

    log "Capturing '$scenario' on $device_id ($serial)"
    adb -s "$serial" shell am force-stop "$BUNDLE_ID" >/dev/null 2>&1 || true

    if ! (
      cd "$ROOT_DIR"
      flutter run \
        -d "$serial" \
        --debug \
        --no-resident \
        --target lib/main_screenshot.dart \
        --dart-define SCREENSHOT_SCENARIO="$scenario"
    ) >"$scenario_log" 2>&1 </dev/null; then
      handle_device_failure "$required" "flutter run failed for $device_id/$scenario. See $scenario_log" || return 1
      return 0
    fi

    sleep "$SETTLE_SECONDS"
    if ! capture_screenshot "$serial" "$scenario" "$screenshot_path"; then
      handle_device_failure "$required" "screencap failed for $device_id/$scenario" || return 1
      return 0
    fi

    if [[ ! -s "$screenshot_path" ]]; then
      handle_device_failure "$required" "Screenshot file is empty: $screenshot_path" || return 1
      return 0
    fi
  done

  log "Completed device '$device_id'"
}

require_command flutter
require_command emulator
require_command adb
require_command jq

if [[ ! -f "$DEVICES_FILE" ]]; then
  error "Devices file not found: $DEVICES_FILE"
  exit 1
fi

if ! jq -e 'type == "array" and all(.[]; has("id") and has("avd_name") and has("tag") and has("output_subdir") and has("required"))' "$DEVICES_FILE" >/dev/null; then
  error "Invalid devices file schema: $DEVICES_FILE"
  exit 1
fi

SCENARIOS=()
while IFS= read -r raw; do
  scenario="$(printf '%s' "$raw" | xargs)"
  if [[ -n "$scenario" ]]; then
    SCENARIOS+=("$scenario")
  fi
done < <(printf '%s\n' "$SCENARIOS_CSV" | tr ',' '\n')

if [[ "${#SCENARIOS[@]}" -eq 0 ]]; then
  error "No scenarios configured. Set ANDROID_SCREENSHOT_SCENARIOS."
  exit 1
fi

for scenario in "${SCENARIOS[@]}"; do
  is_valid=0
  for allowed in "${VALID_SCENARIOS[@]}"; do
    if [[ "$scenario" == "$allowed" ]]; then
      is_valid=1
      break
    fi
  done
  if [[ "$is_valid" -eq 0 ]]; then
    error "Invalid scenario '$scenario'. Allowed values: ${VALID_SCENARIOS[*]}"
    exit 1
  fi
done

mkdir -p "$OUTPUT_DIR" "$LOGS_DIR"

AVAILABLE_AVDS="$(emulator -list-avds || true)"
if [[ -z "$AVAILABLE_AVDS" ]]; then
  error "No Android AVDs found. Create AVDs before running screenshot automation."
  exit 1
fi

active_devices_json='[]'
while IFS= read -r device_row; do
  avd_name="$(jq -r '.avd_name' <<<"$device_row")"
  required="$(jq -r '.required' <<<"$device_row")"

  avd_found=0
  if printf '%s\n' "$AVAILABLE_AVDS" | grep -Fxq "$avd_name"; then
    avd_found=1
  fi

  if [[ "$avd_found" -eq 1 ]]; then
    active_devices_json="$(jq -c --argjson row "$device_row" '. + [$row]' <<<"$active_devices_json")"
    continue
  fi

  if [[ "$required" == "true" ]]; then
    error "Required AVD missing: $avd_name"
    exit 1
  fi
  warn "Optional AVD missing, skipping: $avd_name"
done < <(jq -c '.[]' "$DEVICES_FILE")

active_count="$(jq 'length' <<<"$active_devices_json")"
if [[ "$active_count" -eq 0 ]]; then
  error "No active devices to capture."
  exit 1
fi

if [[ "$SKIP_BUILD" != "1" ]]; then
  build_log="$LOGS_DIR/flutter_build.log"
  log "Running pre-build (set ANDROID_SCREENSHOT_SKIP_BUILD=1 to skip)"
  if ! (
    cd "$ROOT_DIR"
    flutter build apk --debug --target lib/main_screenshot.dart
  ) >"$build_log" 2>&1; then
    error "flutter build failed. See $build_log"
    exit 1
  fi
fi

active_devices_file="$(mktemp)"
device_rows_file="$(mktemp)"
trap 'rm -f "$active_devices_file" "$device_rows_file"' EXIT
printf '%s\n' "$active_devices_json" >"$active_devices_file"
jq -c '.[]' "$active_devices_file" >"$device_rows_file"

overall_failure=0
if [[ "$PARALLEL_DEVICES" == "1" ]]; then
  log "Running device captures in parallel"
  pids=()
  exec 3<"$device_rows_file"
  while IFS= read -r -u 3 device_row; do
    run_device_capture "$device_row" &
    pids+=("$!")
  done
  exec 3<&-

  for pid in "${pids[@]}"; do
    if ! wait "$pid"; then
      overall_failure=1
    fi
  done
else
  exec 3<"$device_rows_file"
  while IFS= read -r -u 3 device_row; do
    if ! run_device_capture "$device_row"; then
      overall_failure=1
      break
    fi
  done
  exec 3<&-
fi

SCENARIOS_CSV_NORMALIZED="$(join_by ',' "${SCENARIOS[@]}")"

if ! "$ROOT_DIR/tool/android/validate_screenshots.sh" \
  "$OUTPUT_DIR" \
  "$active_devices_file" \
  "$SCENARIOS_CSV_NORMALIZED"; then
  overall_failure=1
fi

if [[ "$overall_failure" -ne 0 ]]; then
  error "Android screenshot automation completed with failures. See logs in $LOGS_DIR"
  exit 1
fi

log "Screenshots saved to: $OUTPUT_DIR"
log "Manifest saved to: $OUTPUT_DIR/manifest.json"
