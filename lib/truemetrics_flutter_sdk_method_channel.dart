import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'truemetrics_flutter_sdk_platform_interface.dart';
import 'truemetrics_config.dart';
import 'truemetrics_state.dart';
import 'upload_statistics.dart';
import 'sensor_statistics.dart';

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

  @override
  Future<UploadStatistics?> getUploadStatistics() async {
    try {
      final result = await methodChannel.invokeMapMethod<String, dynamic>('getUploadStatistics');
      if (result == null) return null;
      return UploadStatistics.fromMap(result);
    } on PlatformException catch (e) {
      debugPrint('Failed to get upload statistics: ${e.message}');
      return null;
    }
  }

  @override
  Future<List<SensorStatistics>> getSensorStatistics() async {
    try {
      final result = await methodChannel.invokeListMethod<Map>('getSensorStatistics');
      if (result == null) return [];
      return result
          .map((item) => SensorStatistics.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } on PlatformException catch (e) {
      debugPrint('Failed to get sensor statistics: ${e.message}');
      return [];
    }
  }

  @override
  Future<void> createMetadataTemplate(String templateName, Map<String, String> templateData) async {
    try {
      await methodChannel.invokeMethod<void>('createMetadataTemplate', {
        'templateName': templateName,
        'templateData': templateData,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to create metadata template: ${e.message}');
    }
  }

  @override
  Future<Map<String, String>?> getMetadataTemplate(String templateName) async {
    try {
      final result = await methodChannel.invokeMapMethod<String, String>(
        'getMetadataTemplate',
        {'templateName': templateName},
      );
      return result;
    } on PlatformException catch (e) {
      debugPrint('Failed to get metadata template: ${e.message}');
      return null;
    }
  }

  @override
  Future<Set<String>> getMetadataTemplateNames() async {
    try {
      final result = await methodChannel.invokeListMethod<String>('getMetadataTemplateNames');
      return result?.toSet() ?? {};
    } on PlatformException catch (e) {
      debugPrint('Failed to get metadata template names: ${e.message}');
      return {};
    }
  }

  @override
  Future<bool> removeMetadataTemplate(String templateName) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'removeMetadataTemplate',
        {'templateName': templateName},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to remove metadata template: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> createMetadataFromTemplate(String tag, String templateName) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'createMetadataFromTemplate',
        {'tag': tag, 'templateName': templateName},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to create metadata from template: ${e.message}');
      return false;
    }
  }

  @override
  Future<void> appendToMetadataTag(String tag, Map<String, String> metadata) async {
    try {
      await methodChannel.invokeMethod<void>('appendToMetadataTag', {
        'tag': tag,
        'metadata': metadata,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to append to metadata tag: ${e.message}');
    }
  }

  @override
  Future<void> appendSingleToMetadataTag(String tag, String key, String value) async {
    try {
      await methodChannel.invokeMethod<void>('appendSingleToMetadataTag', {
        'tag': tag,
        'key': key,
        'value': value,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to append single to metadata tag: ${e.message}');
    }
  }

  @override
  Future<Map<String, String>?> getMetadataByTag(String tag) async {
    try {
      final result = await methodChannel.invokeMapMethod<String, String>(
        'getMetadataByTag',
        {'tag': tag},
      );
      return result;
    } on PlatformException catch (e) {
      debugPrint('Failed to get metadata by tag: ${e.message}');
      return null;
    }
  }

  @override
  Future<Set<String>> getMetadataTags() async {
    try {
      final result = await methodChannel.invokeListMethod<String>('getMetadataTags');
      return result?.toSet() ?? {};
    } on PlatformException catch (e) {
      debugPrint('Failed to get metadata tags: ${e.message}');
      return {};
    }
  }

  @override
  Future<bool> logMetadataByTag(String tag) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'logMetadataByTag',
        {'tag': tag},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to log metadata by tag: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> removeMetadataTag(String tag) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'removeMetadataTag',
        {'tag': tag},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to remove metadata tag: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> removeFromMetadataTag(String tag, String key) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'removeFromMetadataTag',
        {'tag': tag, 'key': key},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to remove from metadata tag: ${e.message}');
      return false;
    }
  }

  @override
  Future<void> clearAllMetadata() async {
    try {
      await methodChannel.invokeMethod<void>('clearAllMetadata');
    } on PlatformException catch (e) {
      throw Exception('Failed to clear all metadata: ${e.message}');
    }
  }
}
