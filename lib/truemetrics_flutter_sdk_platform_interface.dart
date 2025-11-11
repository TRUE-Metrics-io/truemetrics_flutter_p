import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:truemetrics_flutter_sdk/truemetrics_config.dart';
import 'truemetrics_flutter_sdk_method_channel.dart';
import 'truemetrics_state.dart';

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
}
