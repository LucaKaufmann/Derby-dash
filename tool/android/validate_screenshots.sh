#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_DIR="${1:-$ROOT_DIR/android/play_store_screenshots}"
DEVICES_FILE="${2:-${ANDROID_SCREENSHOT_DEVICES_FILE:-$ROOT_DIR/tool/android/screenshot_devices.json}}"
SCENARIOS_CSV="${3:-${ANDROID_SCREENSHOT_SCENARIOS:-home,garage,dashboard,bracket,history,champion,standings}}"
BUNDLE_ID="${ANDROID_SCREENSHOT_BUNDLE_ID:-com.codable.derbydash}"
LOCALE="${ANDROID_SCREENSHOT_LOCALE:-en-US}"
MANIFEST_PATH="$OUTPUT_DIR/manifest.json"

VALID_SCENARIOS=(
  home
  garage
  dashboard
  bracket
  history
  champion
  standings
)

require_command() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    echo "Missing required command: $name" >&2
    exit 1
  fi
}

json_array_from_lines() {
  local source_file="$1"
  if [[ -s "$source_file" ]]; then
    jq -R . <"$source_file" | jq -s .
  else
    echo "[]"
  fi
}

require_command jq
require_command file

if [[ ! -f "$DEVICES_FILE" ]]; then
  echo "Devices file not found: $DEVICES_FILE" >&2
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
  echo "No scenarios configured. Set ANDROID_SCREENSHOT_SCENARIOS." >&2
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
    echo "Invalid scenario '$scenario'. Allowed values: ${VALID_SCENARIOS[*]}" >&2
    exit 1
  fi
done

if ! jq -e 'type == "array" and all(.[]; has("id") and has("avd_name") and has("tag") and has("output_subdir") and has("required"))' "$DEVICES_FILE" >/dev/null; then
  echo "Invalid devices file schema: $DEVICES_FILE" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

RUN_TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
HAS_SIPS=0
if command -v sips >/dev/null 2>&1; then
  HAS_SIPS=1
fi

missing_file_list="$(mktemp)"
invalid_file_list="$(mktemp)"
manifest_entries_file="$(mktemp)"
scenarios_list_file="$(mktemp)"
trap 'rm -f "$missing_file_list" "$invalid_file_list" "$manifest_entries_file" "$scenarios_list_file"' EXIT

printf '%s\n' "${SCENARIOS[@]}" >"$scenarios_list_file"

expected_count=0

while IFS= read -r device_row; do
  id="$(jq -r '.id' <<<"$device_row")"
  tag="$(jq -r '.tag' <<<"$device_row")"
  output_subdir="$(jq -r '.output_subdir' <<<"$device_row")"

  for scenario in "${SCENARIOS[@]}"; do
    expected_count=$((expected_count + 1))
    screenshot_path="$OUTPUT_DIR/$output_subdir/${scenario}_${tag}.png"

    if [[ ! -f "$screenshot_path" ]]; then
      echo "$screenshot_path" >>"$missing_file_list"
      continue
    fi

    if [[ ! -s "$screenshot_path" ]]; then
      echo "$screenshot_path (empty file)" >>"$invalid_file_list"
      continue
    fi

    file_type="$(file -b "$screenshot_path" || true)"
    if [[ "$file_type" != PNG* ]]; then
      echo "$screenshot_path (not a PNG: $file_type)" >>"$invalid_file_list"
      continue
    fi

    width_json="null"
    height_json="null"
    if [[ "$HAS_SIPS" -eq 1 ]]; then
      width="$(sips -g pixelWidth "$screenshot_path" 2>/dev/null | awk '/pixelWidth:/{print $2}')"
      height="$(sips -g pixelHeight "$screenshot_path" 2>/dev/null | awk '/pixelHeight:/{print $2}')"
      if [[ -n "$width" && -n "$height" ]]; then
        width_json="$width"
        height_json="$height"
      fi
    fi

    size_bytes="$(wc -c <"$screenshot_path" | tr -d '[:space:]')"
    relative_path="${screenshot_path#$ROOT_DIR/}"
    jq -cn \
      --arg device_id "$id" \
      --arg scenario "$scenario" \
      --arg path "$relative_path" \
      --argjson width "$width_json" \
      --argjson height "$height_json" \
      --argjson size_bytes "$size_bytes" \
      '{device_id:$device_id,scenario:$scenario,path:$path,width:$width,height:$height,size_bytes:$size_bytes}' \
      >>"$manifest_entries_file"
  done
done < <(jq -c '.[]' "$DEVICES_FILE")

if [[ -s "$manifest_entries_file" ]]; then
  files_json="$(jq -s . <"$manifest_entries_file")"
else
  files_json="[]"
fi

missing_json="$(json_array_from_lines "$missing_file_list")"
invalid_json="$(json_array_from_lines "$invalid_file_list")"
scenarios_json="$(json_array_from_lines "$scenarios_list_file")"
devices_json="$(jq -c '.' "$DEVICES_FILE")"

actual_count="$(jq 'length' <<<"$files_json")"
missing_count="$(jq 'length' <<<"$missing_json")"
invalid_count="$(jq 'length' <<<"$invalid_json")"

status="passed"
if [[ "$missing_count" -gt 0 || "$invalid_count" -gt 0 ]]; then
  status="failed"
fi

jq -n \
  --arg run_timestamp "$RUN_TIMESTAMP" \
  --arg bundle_id "$BUNDLE_ID" \
  --arg locale "$LOCALE" \
  --arg status "$status" \
  --argjson expected_count "$expected_count" \
  --argjson actual_count "$actual_count" \
  --argjson scenarios "$scenarios_json" \
  --argjson devices "$devices_json" \
  --argjson files "$files_json" \
  --argjson missing_files "$missing_json" \
  --argjson invalid_files "$invalid_json" \
  '{
    run_timestamp: $run_timestamp,
    bundle_id: $bundle_id,
    locale: $locale,
    status: $status,
    expected_count: $expected_count,
    actual_count: $actual_count,
    scenarios: $scenarios,
    devices: $devices,
    files: $files,
    missing_files: $missing_files,
    invalid_files: $invalid_files
  }' >"$MANIFEST_PATH"

if [[ "$status" != "passed" ]]; then
  echo "Validation failed for screenshots in $OUTPUT_DIR" >&2
  echo "Manifest generated at: $MANIFEST_PATH" >&2
  exit 1
fi

echo "Validation passed: $actual_count/$expected_count screenshots captured."
echo "Manifest generated at: $MANIFEST_PATH"
