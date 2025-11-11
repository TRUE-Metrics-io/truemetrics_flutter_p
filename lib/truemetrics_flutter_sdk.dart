
import 'package:truemetrics_flutter_sdk/truemetrics_config.dart';
import 'truemetrics_flutter_sdk_platform_interface.dart';

export 'truemetrics_config.dart';

class TruemetricsFlutterSdk {
  Future<bool?> isInitialized() {
    return TruemetricsFlutterSdkPlatform.instance.isInitialized();
  }

  void setStatusListener({
    StateChangeCallback? onStateChange,
    ErrorCallback? onError,
    PermissionsCallback? onPermissionsRequired,
  }) {
    TruemetricsFlutterSdkPlatform.instance.setStatusListener(
      onStateChange: onStateChange,
      onError: onError,
      onPermissionsRequired: onPermissionsRequired,
    );
  }

  void removeStatusListener() {
    TruemetricsFlutterSdkPlatform.instance.removeStatusListener();
  }

  Future<String> initialize(TruemetricsConfig config) {
    return TruemetricsFlutterSdkPlatform.instance.initialize(config);
  }

  Future<void> stopRecording() {
    return TruemetricsFlutterSdkPlatform.instance.stopRecording();
  }

  Future<void> startRecording() {
    return TruemetricsFlutterSdkPlatform.instance.startRecording();
  }

  Future<void> deInitialize() {
    return TruemetricsFlutterSdkPlatform.instance.deInitialize();
  }

  Future<void> logMetadata(Map<String, String> params) {
    return TruemetricsFlutterSdkPlatform.instance.logMetadata(params);
  }

  Future<String?> getDeviceId() {
    return TruemetricsFlutterSdkPlatform.instance.getDeviceId();
  }
}
