# truemetrics_flutter_sdk

A Flutter plugin for Truemetrics SDK.

## Getting Started

To use this plugin, add `truemetrics_flutter_sdk` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  truemetrics_flutter_sdk: ^0.0.5
```

## Usage

Initialize the SDK

```dart
final sdk = TruemetricsFlutterSdk();
final config = TruemetricsConfig(
  config: {
    'apiKey': 'your-api-key',
    'delayAutoStartRecording': TruemetricsConfig.autoStartOnInit,
  },
);
await sdk.initialize(config);
```

Start recording

```dart
await sdk.startRecording();
```

Log metadata

```dart
await sdk.logMetadata({'key': 'value'});
```

Stop recording

```dart
await sdk.stopRecording();
```