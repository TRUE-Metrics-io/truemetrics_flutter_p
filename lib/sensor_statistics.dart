enum SensorDataQuality {
  /// 95-100% of configured frequency
  excellent,

  /// 80-95% of configured frequency
  good,

  /// 50-80% of configured frequency
  poor,

  /// Less than 50% of configured frequency
  bad,

  /// No data available or sensor not recording
  unknown;

  static SensorDataQuality fromNativeString(String value) {
    switch (value) {
      case 'EXCELLENT':
        return SensorDataQuality.excellent;
      case 'GOOD':
        return SensorDataQuality.good;
      case 'POOR':
        return SensorDataQuality.poor;
      case 'BAD':
        return SensorDataQuality.bad;
      case 'UNKNOWN':
      default:
        return SensorDataQuality.unknown;
    }
  }
}

class SensorStatistics {
  final String sensorName;
  final double configuredFrequencyHz;
  final double actualFrequencyHz;
  final SensorDataQuality quality;

  const SensorStatistics({
    required this.sensorName,
    required this.configuredFrequencyHz,
    required this.actualFrequencyHz,
    required this.quality,
  });

  factory SensorStatistics.fromMap(Map<String, dynamic> map) {
    return SensorStatistics(
      sensorName: map['sensorName'] as String,
      configuredFrequencyHz: (map['configuredFrequencyHz'] as num).toDouble(),
      actualFrequencyHz: (map['actualFrequencyHz'] as num).toDouble(),
      quality: SensorDataQuality.fromNativeString(map['quality'] as String),
    );
  }

  @override
  String toString() =>
      'SensorStatistics(sensorName: $sensorName, '
      'configuredFrequencyHz: $configuredFrequencyHz, '
      'actualFrequencyHz: $actualFrequencyHz, '
      'quality: $quality)';
}
