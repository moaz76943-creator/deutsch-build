/// مقاييس حقيقية لسلامة قاعدة البيانات
class DatabaseHealthMetrics {
  final bool isIntegrityOk;
  final int schemaVersion;
  final int freeSpaceBytes;
  final int walSizeEstimate;

  const DatabaseHealthMetrics({
    required this.isIntegrityOk,
    required this.schemaVersion,
    required this.freeSpaceBytes,
    required this.walSizeEstimate,
  });

  bool get isHealthy => isIntegrityOk && schemaVersion > 0;
}
