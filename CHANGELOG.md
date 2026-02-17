## 0.0.5

- Updated native Android SDK to 1.4.2
- Added Statistics APIs:
  - `getUploadStatistics()` - returns upload count and last successful upload timestamp
  - `getSensorStatistics()` - returns per-sensor frequency and quality data
- Added Metadata Templates APIs:
  - Template management: `createMetadataTemplate()`, `getMetadataTemplate()`, `getMetadataTemplateNames()`, `removeMetadataTemplate()`
  - Tagged metadata: `createMetadataFromTemplate()`, `appendToMetadataTag()`, `appendSingleToMetadataTag()`, `getMetadataByTag()`, `getMetadataTags()`, `logMetadataByTag()`, `removeMetadataTag()`, `removeFromMetadataTag()`, `clearAllMetadata()`
- Added Recording State APIs:
  - `isRecordingInProgress()` - check if recording is currently active
  - `isRecordingStopped()` - check if recording has been stopped
  - `getRecordingStartTime()` - get the timestamp when recording started
- Added Sensor Control APIs:
  - `setAllSensorsEnabled()` - enable or disable all sensors
  - `getAllSensorsEnabled()` - check if all sensors are enabled
- Added Sensor Info API:
  - `getSensorInfo()` - returns current sensor information (name, status, frequency, missing permissions)
- Added Configuration APIs:
  - `getActiveConfig()` - returns the active SDK configuration from the server
  - `onConfigChange` callback in `setStatusListener()` for live configuration updates
- **BREAKING**: `StateChangeCallback` now receives `TruemetricsStatusEvent` instead of `TruemetricsState` enum
  - Access state via `event.state`, device ID via `event.deviceId`, delay via `event.delayMs`
  - `deviceId` is now directly available in `initialized`, `recordingInProgress`, and `delayedStart` events
  - `delayMs` is now included in `delayedStart` events
- Added new state: `readingsDatabaseFull` - indicates the readings database is full due to insufficient storage
- Added new model classes: `UploadStatistics`, `SensorStatistics`, `SensorDataQuality`, `TruemetricsConfiguration`, `UploadMode`, `TrafficStatus`, `SensorInfo`, `SensorName`, `SensorStatus`, `TruemetricsStatusEvent`
- All public types now exported from the main barrel file (`truemetrics_flutter_sdk.dart`)

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
