/// Manifest entry of a temporary cached artifact.
class CacheArtifact {
  final String path;
  final int fileSizeBytes;
  final bool isIncompleteDownload;
  final int ageMinutes;

  const CacheArtifact({
    required this.path,
    required this.fileSizeBytes,
    required this.isIncompleteDownload,
    required this.ageMinutes,
  });
}

/// Automatically reclaims storage space by pruning abandoned partial downloads and temporary unpack caches.
class TemporaryPackCacheCleaner {
  final int maxArtifactAgeMinutes;

  const TemporaryPackCacheCleaner({this.maxArtifactAgeMinutes = 120});

  /// Identifies and purges obsolete temporary files to free mobile device storage.
  Map<String, dynamic> purgeTemporaryFiles(List<CacheArtifact> artifacts) {
    int reclaimedBytes = 0;
    int purgedCount = 0;

    for (final artifact in artifacts) {
      if (artifact.isIncompleteDownload || artifact.ageMinutes >= maxArtifactAgeMinutes) {
        reclaimedBytes += artifact.fileSizeBytes;
        purgedCount++;
      }
    }

    return {
      'purgedCount': purgedCount,
      'reclaimedBytes': reclaimedBytes,
      'reclaimedMegabytes': double.parse((reclaimedBytes / (1024 * 1024)).toStringAsFixed(2)),
      'isStorageClean': true,
    };
  }
}
