
import 'package:truemetrics_flutter_sdk/truemetrics_config.dart';
import 'truemetrics_flutter_sdk_platform_interface.dart';
import 'upload_statistics.dart';
import 'sensor_statistics.dart';
import 'configuration.dart';
import 'sensor_info.dart';

export 'truemetrics_config.dart';
export 'truemetrics_state.dart';
export 'truemetrics_error.dart';
export 'upload_statistics.dart';
export 'sensor_statistics.dart';
export 'configuration.dart';
export 'sensor_info.dart';

class TruemetricsFlutterSdk {
  Future<bool?> isInitialized() {
    return TruemetricsFlutterSdkPlatform.instance.isInitialized();
  }

  void setStatusListener({
    StateChangeCallback? onStateChange,
    ErrorCallback? onError,
    PermissionsCallback? onPermissionsRequired,
    ConfigChangeCallback? onConfigChange,
  }) {
    TruemetricsFlutterSdkPlatform.instance.setStatusListener(
      onStateChange: onStateChange,
      onError: onError,
      onPermissionsRequired: onPermissionsRequired,
      onConfigChange: onConfigChange,
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

  // --- Recording State APIs ---

  Future<bool> isRecordingInProgress() {
    return TruemetricsFlutterSdkPlatform.instance.isRecordingInProgress();
  }

  Future<bool> isRecordingStopped() {
    return TruemetricsFlutterSdkPlatform.instance.isRecordingStopped();
  }

  Future<int> getRecordingStartTime() {
    return TruemetricsFlutterSdkPlatform.instance.getRecordingStartTime();
  }

  // --- Sensor APIs ---

  Future<void> setAllSensorsEnabled(bool enabled) {
    return TruemetricsFlutterSdkPlatform.instance.setAllSensorsEnabled(enabled);
  }

  Future<bool> getAllSensorsEnabled() {
    return TruemetricsFlutterSdkPlatform.instance.getAllSensorsEnabled();
  }

  Future<List<SensorInfo>> getSensorInfo() {
    return TruemetricsFlutterSdkPlatform.instance.getSensorInfo();
  }

  // --- Statistics APIs ---

  Future<UploadStatistics?> getUploadStatistics() {
    return TruemetricsFlutterSdkPlatform.instance.getUploadStatistics();
  }

  Future<List<SensorStatistics>> getSensorStatistics() {
    return TruemetricsFlutterSdkPlatform.instance.getSensorStatistics();
  }

  // --- Configuration APIs ---

  Future<TruemetricsConfiguration?> getActiveConfig() {
    return TruemetricsFlutterSdkPlatform.instance.getActiveConfig();
  }

  // --- Metadata Template APIs ---

  Future<void> createMetadataTemplate(String templateName, Map<String, String> templateData) {
    return TruemetricsFlutterSdkPlatform.instance.createMetadataTemplate(templateName, templateData);
  }

  Future<Map<String, String>?> getMetadataTemplate(String templateName) {
    return TruemetricsFlutterSdkPlatform.instance.getMetadataTemplate(templateName);
  }

  Future<Set<String>> getMetadataTemplateNames() {
    return TruemetricsFlutterSdkPlatform.instance.getMetadataTemplateNames();
  }

  Future<bool> removeMetadataTemplate(String templateName) {
    return TruemetricsFlutterSdkPlatform.instance.removeMetadataTemplate(templateName);
  }

  Future<bool> createMetadataFromTemplate(String tag, String templateName) {
    return TruemetricsFlutterSdkPlatform.instance.createMetadataFromTemplate(tag, templateName);
  }

  Future<void> appendToMetadataTag(String tag, Map<String, String> metadata) {
    return TruemetricsFlutterSdkPlatform.instance.appendToMetadataTag(tag, metadata);
  }

  Future<void> appendSingleToMetadataTag(String tag, String key, String value) {
    return TruemetricsFlutterSdkPlatform.instance.appendSingleToMetadataTag(tag, key, value);
  }

  Future<Map<String, String>?> getMetadataByTag(String tag) {
    return TruemetricsFlutterSdkPlatform.instance.getMetadataByTag(tag);
  }

  Future<Set<String>> getMetadataTags() {
    return TruemetricsFlutterSdkPlatform.instance.getMetadataTags();
  }

  Future<bool> logMetadataByTag(String tag) {
    return TruemetricsFlutterSdkPlatform.instance.logMetadataByTag(tag);
  }

  Future<bool> removeMetadataTag(String tag) {
    return TruemetricsFlutterSdkPlatform.instance.removeMetadataTag(tag);
  }

  Future<bool> removeFromMetadataTag(String tag, String key) {
    return TruemetricsFlutterSdkPlatform.instance.removeFromMetadataTag(tag, key);
  }

  Future<void> clearAllMetadata() {
    return TruemetricsFlutterSdkPlatform.instance.clearAllMetadata();
  }
}
