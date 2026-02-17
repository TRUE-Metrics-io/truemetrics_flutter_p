/// Mode controlling how data uploads occur.
enum UploadMode {
  wifiOnly,
  any,
  metadataTriggered;

  static UploadMode fromNativeString(String value) {
    switch (value) {
      case 'WIFI_ONLY':
        return UploadMode.wifiOnly;
      case 'ANY':
        return UploadMode.any;
      case 'METADATA_TRIGGERED':
        return UploadMode.metadataTriggered;
      default:
        throw ArgumentError('Unknown UploadMode: $value');
    }
  }
}

/// Whether the traffic limit has been reached.
enum TrafficStatus {
  notReached,
  reached;

  static TrafficStatus fromNativeString(String value) {
    switch (value) {
      case 'NOT_REACHED':
        return TrafficStatus.notReached;
      case 'REACHED':
        return TrafficStatus.reached;
      default:
        throw ArgumentError('Unknown TrafficStatus: $value');
    }
  }
}

/// The active SDK configuration as received from the server.
class TruemetricsConfiguration {
  final UploadMode uploadMode;
  final double fusedLocationPollFreq;
  final double accelerometerPollFreq;
  final double gyroscopePollFreq;
  final double magnetometerPollFreq;
  final double barometerPollFreq;
  final double gnssPollFreq;
  final double rawLocationPollFreq;
  final double wifiPollFreq;
  final double batteryPollFreq;
  final double stepCounterPollFreq;
  final double motionModePollFreq;
  final double mobileDataSignalPollFreq;
  final double fopPollFreq;
  final String endpoint;
  final TrafficStatus trafficLimitReached;
  final int updateConfigPeriodSec;
  final int bufferLengthMinutes;
  final int uploadPeriodSeconds;
  final bool useWorkManager;
  final int payloadLimitKb;

  const TruemetricsConfiguration({
    required this.uploadMode,
    required this.fusedLocationPollFreq,
    required this.accelerometerPollFreq,
    required this.gyroscopePollFreq,
    required this.magnetometerPollFreq,
    required this.barometerPollFreq,
    required this.gnssPollFreq,
    required this.rawLocationPollFreq,
    required this.wifiPollFreq,
    required this.batteryPollFreq,
    required this.stepCounterPollFreq,
    required this.motionModePollFreq,
    required this.mobileDataSignalPollFreq,
    required this.fopPollFreq,
    required this.endpoint,
    required this.trafficLimitReached,
    required this.updateConfigPeriodSec,
    required this.bufferLengthMinutes,
    required this.uploadPeriodSeconds,
    required this.useWorkManager,
    required this.payloadLimitKb,
  });

  factory TruemetricsConfiguration.fromMap(Map<String, dynamic> map) {
    return TruemetricsConfiguration(
      uploadMode: UploadMode.fromNativeString(map['uploadMode'] as String),
      fusedLocationPollFreq: (map['fusedLocationPollFreq'] as num).toDouble(),
      accelerometerPollFreq: (map['accelerometerPollFreq'] as num).toDouble(),
      gyroscopePollFreq: (map['gyroscopePollFreq'] as num).toDouble(),
      magnetometerPollFreq: (map['magnetometerPollFreq'] as num).toDouble(),
      barometerPollFreq: (map['barometerPollFreq'] as num).toDouble(),
      gnssPollFreq: (map['gnssPollFreq'] as num).toDouble(),
      rawLocationPollFreq: (map['rawLocationPollFreq'] as num).toDouble(),
      wifiPollFreq: (map['wifiPollFreq'] as num).toDouble(),
      batteryPollFreq: (map['batteryPollFreq'] as num).toDouble(),
      stepCounterPollFreq: (map['stepCounterPollFreq'] as num).toDouble(),
      motionModePollFreq: (map['motionModePollFreq'] as num).toDouble(),
      mobileDataSignalPollFreq: (map['mobileDataSignalPollFreq'] as num).toDouble(),
      fopPollFreq: (map['fopPollFreq'] as num).toDouble(),
      endpoint: map['endpoint'] as String,
      trafficLimitReached: TrafficStatus.fromNativeString(map['trafficLimitReached'] as String),
      updateConfigPeriodSec: map['updateConfigPeriodSec'] as int,
      bufferLengthMinutes: map['bufferLengthMinutes'] as int,
      uploadPeriodSeconds: map['uploadPeriodSeconds'] as int,
      useWorkManager: map['useWorkManager'] as bool,
      payloadLimitKb: map['payloadLimitKb'] as int,
    );
  }

  @override
  String toString() =>
      'TruemetricsConfiguration(uploadMode: $uploadMode, endpoint: $endpoint, '
      'trafficLimitReached: $trafficLimitReached)';
}
