## 0.0.4

- Updated native Android SDK to 1.3.3
- **BREAKING BEHAVIOR CHANGE**: Recording now starts automatically after `initialize()` by default. In v1.2.2, you needed to explicitly call `startRecording()`. To restore the old behavior, use `'delayAutoStartRecording': TruemetricsConfig.explicitStart` in config.
- Added new states: `delayedStart` and `trafficLimitReached`
- Added `delayAutoStartRecording` config parameter:
  - `TruemetricsConfig.explicitStart` (-1) - recording starts only when you call `startRecording()` (old v1.2.2 behavior)
  - `TruemetricsConfig.autoStartOnInit` (0) - recording starts automatically after initialization (new default)
  - Any positive number (milliseconds) - delay before auto-starting recording
- Added `getDeviceId()` method to retrieve device identifier
- Removed `debug` parameter (not supported in SDK 1.3.3)
- Note: `deviceId` is no longer returned from `initialize()` method, use `getDeviceId()` instead

## 0.0.3

- Use truemetrics-sdk version 1.2.0

## 0.0.2

- Initial release
