/// Cached audio asset metadata.
class CachedAudioAsset {
  final String assetId;
  final int fileSizeBytes;
  final int lastAccessedEpochDays;
  final bool isCoreEssentialA1;

  const CachedAudioAsset({
    required this.assetId,
    required this.fileSizeBytes,
    required this.lastAccessedEpochDays,
    required this.isCoreEssentialA1,
  });
}

/// Dynamically prunes stale audio cache to keep storage footprints strictly under control.
class AudioPackPruningEngine {
  final int maxCacheBudgetBytes;

  const AudioPackPruningEngine({this.maxCacheBudgetBytes = 104857600}); // 100MB default

  /// Prunes non-essential LRU audio files when cache exceeds budget.
  List<String> identifyAssetsToPrune({
    required List<CachedAudioAsset> currentCache,
    required int availableDiskSpaceMb,
  }) {
    int totalBytes = 0;
    for (final asset in currentCache) {
      totalBytes += asset.fileSizeBytes;
    }

    final toPrune = <String>[];
    if (totalBytes <= maxCacheBudgetBytes && availableDiskSpaceMb > 250) {
      return toPrune; // Storage is healthy
    }

    // Sort candidates: oldest accessed first, preserving core A1 essentials
    final candidates = currentCache.where((a) => !a.isCoreEssentialA1).toList()
      ..sort((a, b) => a.lastAccessedEpochDays.compareTo(b.lastAccessedEpochDays));

    int reclaimedBytes = 0;
    for (final candidate in candidates) {
      toPrune.add(candidate.assetId);
      reclaimedBytes += candidate.fileSizeBytes;
      if (totalBytes - reclaimedBytes <= maxCacheBudgetBytes && availableDiskSpaceMb > 250) {
        break;
      }
    }

    return toPrune;
  }
}
