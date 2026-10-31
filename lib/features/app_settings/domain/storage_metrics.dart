final class StorageMetrics {
  const StorageMetrics({
    required this.localDataBytes,
    this.lastCacheClearAt,
  }) : assert(localDataBytes >= 0);

  final int localDataBytes;
  final DateTime? lastCacheClearAt;

  double get localDataKilobytes => localDataBytes / 1024.0;

  StorageMetrics copyWith({
    int? localDataBytes,
    DateTime? lastCacheClearAt,
  }) {
    return StorageMetrics(
      localDataBytes: localDataBytes ?? this.localDataBytes,
      lastCacheClearAt: lastCacheClearAt ?? this.lastCacheClearAt,
    );
  }
}
