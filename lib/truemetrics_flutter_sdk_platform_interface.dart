import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:truemetrics_flutter_sdk/truemetrics_config.dart';
import 'truemetrics_flutter_sdk_method_channel.dart';
import 'truemetrics_state.dart';
import 'upload_statistics.dart';
import 'sensor_statistics.dart';

typedef StateChangeCallback = void Function(TruemetricsState state);
typedef ErrorCallback = void Function(String errorCode, String? message);
typedef PermissionsCallback = void Function(List<String> permissions);

abstract class TruemetricsFlutterSdkPlatform extends PlatformInterface {
  TruemetricsFlutterSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static TruemetricsFlutterSdkPlatform _instance = MethodChannelTruemetricsFlutterSdk();
  static TruemetricsFlutterSdkPlatform get instance => _instance;

  static set instance(TruemetricsFlutterSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool?> isInitialized() {
    throw UnimplementedError('isInitialized() has not been implemented.');
  }

  void setStatusListener({
    StateChangeCallback? onStateChange,
    ErrorCallback? onError,
    PermissionsCallback? onPermissionsRequired,
  }) {
    throw UnimplementedError('setStatusListener() has not been implemented.');
  }

  void removeStatusListener() {
    throw UnimplementedError('removeStatusListener() has not been implemented.');
  }

  Future<String> initialize(TruemetricsConfig config) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<void> startRecording() {
    throw UnimplementedError('startRecording() has not been implemented.');
  }

  Future<void> stopRecording() {
    throw UnimplementedError('stopRecording() has not been implemented.');
  }

  Future<void> deInitialize() {
    throw UnimplementedError('deInitialize() has not been implemented.');
  }

  Future<void> logMetadata(Map<String, String> params) {
    throw UnimplementedError('logMetadata() has not been implemented.');
  }

  Future<String?> getDeviceId() {
    throw UnimplementedError('getDeviceId() has not been implemented.');
  }

  Future<UploadStatistics?> getUploadStatistics() {
    throw UnimplementedError('getUploadStatistics() has not been implemented.');
  }

  Future<List<SensorStatistics>> getSensorStatistics() {
    throw UnimplementedError('getSensorStatistics() has not been implemented.');
  }

  Future<void> createMetadataTemplate(String templateName, Map<String, String> templateData) {
    throw UnimplementedError('createMetadataTemplate() has not been implemented.');
  }

  Future<Map<String, String>?> getMetadataTemplate(String templateName) {
    throw UnimplementedError('getMetadataTemplate() has not been implemented.');
  }

  Future<Set<String>> getMetadataTemplateNames() {
    throw UnimplementedError('getMetadataTemplateNames() has not been implemented.');
  }

  Future<bool> removeMetadataTemplate(String templateName) {
    throw UnimplementedError('removeMetadataTemplate() has not been implemented.');
  }

  Future<bool> createMetadataFromTemplate(String tag, String templateName) {
    throw UnimplementedError('createMetadataFromTemplate() has not been implemented.');
  }

  Future<void> appendToMetadataTag(String tag, Map<String, String> metadata) {
    throw UnimplementedError('appendToMetadataTag() has not been implemented.');
  }

  Future<void> appendSingleToMetadataTag(String tag, String key, String value) {
    throw UnimplementedError('appendSingleToMetadataTag() has not been implemented.');
  }

  Future<Map<String, String>?> getMetadataByTag(String tag) {
    throw UnimplementedError('getMetadataByTag() has not been implemented.');
  }

  Future<Set<String>> getMetadataTags() {
    throw UnimplementedError('getMetadataTags() has not been implemented.');
  }

  Future<bool> logMetadataByTag(String tag) {
    throw UnimplementedError('logMetadataByTag() has not been implemented.');
  }

  Future<bool> removeMetadataTag(String tag) {
    throw UnimplementedError('removeMetadataTag() has not been implemented.');
  }

  Future<bool> removeFromMetadataTag(String tag, String key) {
    throw UnimplementedError('removeFromMetadataTag() has not been implemented.');
  }

  Future<void> clearAllMetadata() {
    throw UnimplementedError('clearAllMetadata() has not been implemented.');
  }
}
