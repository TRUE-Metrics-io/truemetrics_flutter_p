import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'truemetrics_flutter_sdk_platform_interface.dart';
import 'truemetrics_config.dart';
import 'truemetrics_state.dart';

class MethodChannelTruemetricsFlutterSdk extends TruemetricsFlutterSdkPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('truemetrics_flutter_sdk');

  @visibleForTesting
  final EventChannel eventChannel = const EventChannel('truemetrics_flutter/events');

  StreamSubscription? _eventSubscription;
  StateChangeCallback? _onStateChange;
  ErrorCallback? _onError;
  PermissionsCallback? _onPermissionsRequired;

  @override
  Future<bool?> isInitialized() async {
    final version = await methodChannel.invokeMethod<bool>('isInitialized');
    return version;
  }

  @override
  Future<String> initialize(TruemetricsConfig config) async {
    try {
      final result = await methodChannel.invokeMethod<String>(
        'initialize',
        {
          'config': config.toMap(),
        },
      );
      return result ?? '';
    } on PlatformException catch (e) {
      throw Exception('Failed to initialize TruemetricsSDK: ${e.message}');
    }
  }

  @override
  Future<void> startRecording() async {
    return await methodChannel.invokeMethod<void>('startRecording');
  }

  @override
  Future<void> stopRecording() async {
    return await methodChannel.invokeMethod<void>('stopRecording');
  }

  @override
  Future<void> deInitialize() async {
    return await methodChannel.invokeMethod<void>('deinitialize');
  }

  @override
  Future<void> logMetadata(Map<String, String> params) async {
    try {
      return await methodChannel.invokeMethod<void>(
        'logMetadata',
        params,
      );
    } on PlatformException catch (e) {
      throw Exception('Failed to log metadata: ${e.message}');
    }
  }

  @override
  void setStatusListener({
    StateChangeCallback? onStateChange,
    ErrorCallback? onError,
    PermissionsCallback? onPermissionsRequired,
  }) {
    _eventSubscription?.cancel();

    _onStateChange = onStateChange;
    _onError = onError;
    _onPermissionsRequired = onPermissionsRequired;

    _eventSubscription = eventChannel.receiveBroadcastStream().listen((dynamic event) {
        if (event is! Map) return;

        final String? type = event['type'] as String?;

        switch (type) {
          case 'stateChange':
            final nativeState = event['state'] as String;
            try {
              final state = TruemetricsState.fromNativeString(nativeState);
              _onStateChange?.call(state);
            } catch (e) {
              debugPrint('Error parsing state: $e');
            }
            break;

          case 'error':
            final errorCode = event['errorCode'] as String;
            final message = event['message'] as String?;
            _onError?.call(errorCode, message);
            break;

          case 'permissions':
            final permissions = List<String>.from(event['permissions'] as List);
            _onPermissionsRequired?.call(permissions);
            break;
        }
      },
      onError: (dynamic error) {
        debugPrint('Error in TrueMetrics event channel: $error');
      },
    );
  }

  @override
  void removeStatusListener() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _onStateChange = null;
    _onError = null;
    _onPermissionsRequired = null;
  }

  @override
  Future<String?> getDeviceId() async {
    try {
      final result = await methodChannel.invokeMethod<String>('getDeviceId');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Failed to get device ID: ${e.message}');
      return null;
    }
  }
}
