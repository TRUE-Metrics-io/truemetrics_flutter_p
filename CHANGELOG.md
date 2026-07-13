## 0.0.12

- Updated native Android SDK to 1.5.8
- Offline resilience: in metadata-triggered mode, unsent data is now kept for up to 3 days, so a metadata event arriving late (e.g. after the device was offline) can still upload the data it covers
- If device storage fills up, the SDK now drops the oldest unsent readings to keep recording — preserving the newest data — and recovers automatically once space frees up
- Fixed background uploads that could stop permanently on some devices (aggressive battery/background management) after the system interrupted an upload; uploads now resume automatically
- Fixed data uploads silently stopping for the rest of a session when the SDK was re-initialized right after a shutdown (e.g. after an auth error with a corrected API key)
- Fixed sensor recording that could silently stop while metadata kept being sent — a sensor that can't be initialized (e.g. fused orientation) is now skipped instead of bringing the whole recording down
- Fixed a startup crash when the SDK was initialized without location permission; the background recording service now starts reliably on Android 14+ and uses location once granted
- The SDK now initializes on devices without WiFi hardware (the WiFi sensor is skipped)
- On Android 15, background recording ended by the system is now reported as stopped through the status listener instead of appearing active
- Reduced mobile data usage and battery drain when the server is unreachable; uploads now back off between retries instead of resending continuously
- `payload_limit_kb` now supports values up to 9,000 KB; each upload flushes when the buffer reaches 80% of the limit or the oldest reading exceeds `period_upload`, whichever comes first
- **Action required (Google Play):** the SDK's foreground services no longer use the "special use" foreground-service type. If your Play Console foreground-service declaration listed "special use" for a Truemetrics service, update it to "data sync".

## 0.0.11

- Updated native Android SDK to 1.5.4
- Fixed metadata values being corrupted: characters like `:`, `/`, `\`, `*`, `?`, and `;` are now preserved as sent
- Fixed crash when `StandardMetadata.extra` is `null`
- Fixed a rare crash when the background upload worker was restarted by the system before the host app re-initialized the SDK

## 0.0.10

- Updated native Android SDK to 1.5.3
- Improved crash report accuracy — stack traces now include correct line numbers and method attribution

## 0.0.9

- Updated native Android SDK to 1.5.2
- Fixed spurious error logs when optional stats module is not bundled
- Fixed crash when metadata contains null values (e.g. from Java/Xamarin callers)
- Removed debug recording notification that could appear on some builds

## 0.0.8

- Updated native Android SDK to 1.5.1
- Added `logStandardMetadata(StandardMetadata)` for logging standardized delivery/pickup event metadata with structured fields
- **Deprecated**: `logMetadata(Map)` is deprecated in favor of `logStandardMetadata(StandardMetadata)`
- Fixed device ID rotation attaching a new device ID to sensor data collected before the rotation
- Increased default device ID rotation period from 14 to 30 days

## 0.0.7

- Updated native Android SDK to 1.5.0
- Added new state: `initializing` — emitted during config fetch on startup, SDK retries automatically on recoverable errors
- Device ID rotation is now handled automatically based on server-configured TTL
- **BREAKING**: Removed `getActiveConfig()`, `onConfigChange` callback, and `TruemetricsConfiguration`/`UploadMode`/`TrafficStatus` classes (internal server config not relevant to SDK consumers)
- Multiple bug fixes in the native SDK (see Android SDK 1.5.0 changelog)

## 0.0.6

- Updated native Android SDK to 1.4.6
- Fixed crash on startup when service binding takes longer than expected
- Fixed `startRecording()` not working in several edge cases (called immediately after `init()`, after service reconnect, during engine initialization)
- Fixed `getDeviceId()` returning null after `stopRecording()`
- Fixed error status being silently cleared on `deinitialize()`
- Fixed crash when backend sends invalid payload size limit
- Fixed Sentry version conflict with host apps using Sentry 9.x or other incompatible versions

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
