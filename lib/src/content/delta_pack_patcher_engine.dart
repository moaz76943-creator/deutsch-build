/// Differential patch instruction representing added or modified entries.
class DeltaPatch {
  final int baseVersion;
  final int targetVersion;
  final List<String> insertedEntries;
  final List<String> updatedEntries;
  final List<String> deletedEntryIds;

  const DeltaPatch({
    required this.baseVersion,
    required this.targetVersion,
    required this.insertedEntries,
    required this.updatedEntries,
    required this.deletedEntryIds,
  });

  int get totalOperations => insertedEntries.length + updatedEntries.length + deletedEntryIds.length;
}

/// Applies incremental binary/text delta patches to local language packs without re-downloading entire database.
class DeltaPackPatcherEngine {
  /// Computes bandwidth savings compared to full re-download.
  double calculateBandwidthSavings({
    required int fullPackSizeBytes,
    required int deltaPatchSizeBytes,
  }) {
    if (fullPackSizeBytes <= 0) return 0.0;
    return (((fullPackSizeBytes - deltaPatchSizeBytes) / fullPackSizeBytes) * 100.0).clamp(0.0, 100.0);
  }

  /// Verifies patch applicability given local version.
  bool canApplyPatch({required int currentLocalVersion, required DeltaPatch patch}) {
    return currentLocalVersion == patch.baseVersion && patch.targetVersion > patch.baseVersion;
  }
}
