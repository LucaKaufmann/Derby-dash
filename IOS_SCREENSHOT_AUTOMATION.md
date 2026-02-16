# iOS Screenshot Automation

This repo now includes a screenshot-specific Flutter entrypoint:

- `lib/main_screenshot.dart`
- `ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner-Screenshots.xcscheme`

That entrypoint seeds deterministic mock data and opens a requested screen scenario.

## Option 1 (Implemented): Simulator Automation With Mocked Data

Use the script below to generate App Store screenshots from an iOS simulator:

```bash
./tool/ios/capture_simulator_screenshots.sh
```

Default output folder:

- `ios/app_store_screenshots`

### Optional environment variables

```bash
SCREENSHOT_DEVICE="iPhone 15 Pro Max" \
SCREENSHOT_BUNDLE_ID="com.codable.derbydash" \
SCREENSHOT_SETTLE_SECONDS=4 \
./tool/ios/capture_simulator_screenshots.sh ./ios/app_store_screenshots
```

### Supported screenshot scenarios

- `home`
- `garage`
- `dashboard`
- `bracket`
- `history`
- `champion`
- `standings`

## Option 2 (Recommended for Physical Devices): Fastlane + XCUITest Snapshot

If you need real-device capture (instead of simulator), use Xcode UI tests and Fastlane `snapshot`.

Suggested approach:

1. Add a dedicated Xcode scheme that sets:
   - Flutter target: `lib/main_screenshot.dart`
2. Create UI tests that launch once per scenario and call `snapshot("name")`.
3. Run `fastlane snapshot` against connected devices.

This gives automated physical-device screenshots at the cost of maintaining UI tests.

## Manual Scenario Launch

You can launch one scenario directly:

```bash
flutter run \
  -d "iPhone 15 Pro Max" \
  --profile \
  --target lib/main_screenshot.dart \
  --dart-define SCREENSHOT_SCENARIO=bracket
```
