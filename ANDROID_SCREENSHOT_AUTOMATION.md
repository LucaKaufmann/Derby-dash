# Android Screenshot Automation

This repo includes an Android emulator screenshot pipeline that mirrors the iOS screenshot flow:

- Launches the app through `lib/main_screenshot.dart`
- Seeds deterministic mock data
- Captures the same scenario set as iOS:
  - `home`
  - `garage`
  - `dashboard`
  - `bracket`
  - `history`
  - `champion`
  - `standings`

## End-to-End Command

```bash
./tool/android/capture_emulator_screenshots.sh
```

Default output folder:

- `android/play_store_screenshots`

Output structure:

- `android/play_store_screenshots/phone/*.png`
- `android/play_store_screenshots/tablet7/*.png`
- `android/play_store_screenshots/tablet10/*.png`
- `android/play_store_screenshots/logs/*.log`
- `android/play_store_screenshots/manifest.json`

## Prerequisites

- Flutter CLI
- Android SDK command-line tools with:
  - `emulator`
  - `adb`
- `jq`

Quick checks:

```bash
command -v flutter
command -v emulator
command -v adb
command -v jq
```

## Device Matrix Configuration

Default matrix file:

- `tool/android/screenshot_devices.json`

Schema (array of objects):

- `id`
- `avd_name`
- `tag`
- `output_subdir`
- `required`

Default devices:

- Phone: `Pixel_9_Pro_XL_API_35`
- 7-inch tablet: `Tablet_7in_API_35`
- 10-inch tablet: `Tablet_10in_API_35`

If a `required: true` AVD is missing, the run fails fast.

## Create AVDs (Example)

If you do not have matching AVD names, create them or update `tool/android/screenshot_devices.json`.

```bash
# Example only: pick system images available on your machine.
sdkmanager --install "system-images;android-35;google_apis;x86_64"

avdmanager create avd \
  -n "Pixel_9_Pro_XL_API_35" \
  -k "system-images;android-35;google_apis;x86_64" \
  -d "pixel_9_pro_xl"

avdmanager create avd \
  -n "Tablet_7in_API_35" \
  -k "system-images;android-35;google_apis;x86_64" \
  -d "Nexus 7"

avdmanager create avd \
  -n "Tablet_10in_API_35" \
  -k "system-images;android-35;google_apis;x86_64" \
  -d "pixel_c"
```

## Environment Variables

- `ANDROID_SCREENSHOT_BUNDLE_ID` default `com.codable.derbydash`
- `ANDROID_SCREENSHOT_SETTLE_SECONDS` default `4`
- `ANDROID_SCREENSHOT_DEVICES_FILE` default `tool/android/screenshot_devices.json`
- `ANDROID_SCREENSHOT_SCENARIOS` default `home,garage,dashboard,bracket,history,champion,standings`
- `ANDROID_SCREENSHOT_LOCALE` default `en-US`
- `ANDROID_SCREENSHOT_SKIP_BUILD` default `0`
- `ANDROID_SCREENSHOT_PARALLEL_DEVICES` default `0`

Example:

```bash
ANDROID_SCREENSHOT_SETTLE_SECONDS=5 \
ANDROID_SCREENSHOT_SCENARIOS="home,garage,standings" \
ANDROID_SCREENSHOT_PARALLEL_DEVICES=1 \
./tool/android/capture_emulator_screenshots.sh ./android/play_store_screenshots
```

## Validation and Manifest

The capture script runs validation automatically and generates:

- `android/play_store_screenshots/manifest.json`

You can run validation manually:

```bash
./tool/android/validate_screenshots.sh \
  ./android/play_store_screenshots \
  ./tool/android/screenshot_devices.json \
  home,garage,dashboard,bracket,history,champion,standings
```

The manifest includes:

- run timestamp
- bundle ID
- locale
- scenarios
- device metadata
- expected/actual counts
- per-file path + size + width/height
- missing/invalid files

## Troubleshooting

- `Missing required command`: install the tool shown in the error (`adb`, `emulator`, `jq`, or `flutter`).
- `Required AVD missing`: run `emulator -list-avds` and update `tool/android/screenshot_devices.json` or create the AVD.
- Boot timeout: open `android/play_store_screenshots/logs/*_emulator.log` and verify the emulator image.
- `flutter run` failure: inspect `android/play_store_screenshots/logs/<device>_<scenario>.log`.
- Wrong locale: this first version is optimized for `en-US`.
