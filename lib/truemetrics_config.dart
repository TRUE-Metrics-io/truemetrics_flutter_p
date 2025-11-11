class TruemetricsConfig {
  final Map<String, dynamic> config;
  const TruemetricsConfig({
    required this.config,
  });
  Map<String, dynamic> toMap() => config;

  // Constants for auto-start modes
  static const int explicitStart = -1;
  static const int autoStartOnInit = 0;
}