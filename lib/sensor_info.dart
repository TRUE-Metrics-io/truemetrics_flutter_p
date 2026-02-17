/// Names of sensors available in the SDK.
enum SensorName {
  status,
  magnetometer,
  gnss,
  barometer,
  accelerometer,
  gyroscope,
  location,
  customerMetadata,
  battery,
  connectivity,
  stepCounter,
  motionMode,
  wifiSignal,
  mobileDataSignal,
  rawLocation,
  fusedOrientation;

  static SensorName fromNativeString(String value) {
    switch (value) {
      case 'STATUS':
        return SensorName.status;
      case 'MAGNETOMETER':
        return SensorName.magnetometer;
      case 'GNSS':
        return SensorName.gnss;
      case 'BAROMETER':
        return SensorName.barometer;
      case 'ACCELEROMETER':
        return SensorName.accelerometer;
      case 'GYROSCOPE':
        return SensorName.gyroscope;
      case 'LOCATION':
        return SensorName.location;
      case 'CUSTOMER_METADATA':
        return SensorName.customerMetadata;
      case 'BATTERY':
        return SensorName.battery;
      case 'CONNECTIVITY':
        return SensorName.connectivity;
      case 'STEP_COUNTER':
        return SensorName.stepCounter;
      case 'MOTION_MODE':
        return SensorName.motionMode;
      case 'WIFI_SIGNAL':
        return SensorName.wifiSignal;
      case 'MOBILE_DATA_SIGNAL':
        return SensorName.mobileDataSignal;
      case 'RAW_LOCATION':
        return SensorName.rawLocation;
      case 'FUSED_ORIENTATION':
        return SensorName.fusedOrientation;
      default:
        throw ArgumentError('Unknown SensorName: $value');
    }
  }
}

/// Current status of a sensor.
enum SensorStatus {
  on,
  off,
  na;

  static SensorStatus fromNativeString(String value) {
    switch (value) {
      case 'ON':
        return SensorStatus.on;
      case 'OFF':
        return SensorStatus.off;
      case 'NA':
        return SensorStatus.na;
      default:
        throw ArgumentError('Unknown SensorStatus: $value');
    }
  }
}

/// Information about a single sensor's state.
class SensorInfo {
  final SensorName sensorName;
  final SensorStatus sensorStatus;
  final double frequency;
  final List<String> missingPermissions;

  const SensorInfo({
    required this.sensorName,
    required this.sensorStatus,
    required this.frequency,
    required this.missingPermissions,
  });

  factory SensorInfo.fromMap(Map<String, dynamic> map) {
    return SensorInfo(
      sensorName: SensorName.fromNativeString(map['sensorName'] as String),
      sensorStatus: SensorStatus.fromNativeString(map['sensorStatus'] as String),
      frequency: (map['frequency'] as num).toDouble(),
      missingPermissions: List<String>.from(map['missingPermissions'] as List),
    );
  }

  @override
  String toString() =>
      'SensorInfo(sensorName: $sensorName, sensorStatus: $sensorStatus, '
      'frequency: $frequency, missingPermissions: $missingPermissions)';
}
