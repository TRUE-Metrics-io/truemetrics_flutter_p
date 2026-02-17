class UploadStatistics {
  final int successfulUploadsCount;
  final int? lastSuccessfulUploadTimestamp;

  const UploadStatistics({
    required this.successfulUploadsCount,
    this.lastSuccessfulUploadTimestamp,
  });

  factory UploadStatistics.fromMap(Map<String, dynamic> map) {
    return UploadStatistics(
      successfulUploadsCount: map['successfulUploadsCount'] as int,
      lastSuccessfulUploadTimestamp:
          map['lastSuccessfulUploadTimestamp'] as int?,
    );
  }

  @override
  String toString() =>
      'UploadStatistics(successfulUploadsCount: $successfulUploadsCount, '
      'lastSuccessfulUploadTimestamp: $lastSuccessfulUploadTimestamp)';
}
