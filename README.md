# truemetrics_flutter_sdk

A Flutter plugin for Truemetrics SDK.

## Getting Started

To use this plugin, add `truemetrics_flutter_sdk` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  truemetrics_flutter_sdk: ^0.0.2
```

## Usage

Initialize the SDK
```
final sdk = TruemetricsFlutterSdk();
final config = TruemetricsConfig(config: {
    'apiKey': 'your-api-key'
    });
await sdk.initialize(config);
```

Start recording
```
await sdk.startRecording();
```

Log metadata
```
await sdk.logMetadata({'key': 'value'});
```

Stop recording
```
await sdk.stopRecording();
```