class AudioPackSpec {
  final String packId;
  final String languageCode;
  final String targetCefrLevel;
  final int fileSizeBytes;
  final String sha256Checksum;
  bool isDownloaded;
  DateTime lastAccessedAt;

  AudioPackSpec({
    required this.packId,
    required this.languageCode,
    required this.targetCefrLevel,
    required this.fileSizeBytes,
    required this.sha256Checksum,
    this.isDownloaded = false,
    DateTime? lastAccessedAt,
  }) : lastAccessedAt = lastAccessedAt ?? DateTime.now();

  double get sizeMb => fileSizeBytes / (1024.0 * 1024.0);
}

class DynamicAudioPackDeliveryEngine {
  final Map<String, AudioPackSpec> _catalog = {};
  final double maxAllowedStorageMb;

  DynamicAudioPackDeliveryEngine({this.maxAllowedStorageMb = 120.0}) {
    _registerPacks();
  }

  void _registerPacks() {
    _catalog['core_starter_pack'] = AudioPackSpec(
      packId: 'core_starter_pack',
      languageCode: 'de',
      targetCefrLevel: 'A1',
      fileSizeBytes: 3500000, // 3.5 MB bundled in base
      sha256Checksum: 'sha256_core_starter',
      isDownloaded: true,
    );

    _catalog['de_a1_highres'] = AudioPackSpec(
      packId: 'de_a1_highres',
      languageCode: 'de',
      targetCefrLevel: 'A1',
      fileSizeBytes: 14000000, // 14 MB
      sha256Checksum: 'sha256_de_a1_highres',
      isDownloaded: false,
    );

    _catalog['de_b1_conversational'] = AudioPackSpec(
      packId: 'de_b1_conversational',
      languageCode: 'de',
      targetCefrLevel: 'B1',
      fileSizeBytes: 22000000, // 22 MB
      sha256Checksum: 'sha256_de_b1_conversational',
      isDownloaded: false,
    );

    _catalog['piper_neural_voice_thorsten'] = AudioPackSpec(
      packId: 'piper_neural_voice_thorsten',
      languageCode: 'de',
      targetCefrLevel: 'ALL',
      fileSizeBytes: 34000000, // 34 MB
      sha256Checksum: 'sha256_piper_neural_thorsten',
      isDownloaded: false,
    );
  }

  List<AudioPackSpec> listAvailablePacks() => _catalog.values.toList();

  /// Total space consumed by downloaded audio packs.
  double computeDownloadedStorageMb() {
    return _catalog.values
        .where((p) => p.isDownloaded)
        .fold(0.0, (sum, p) => sum + p.sizeMb);
  }

  /// Downloads or side-loads an audio pack and verifies integrity.
  bool installAudioPack(String packId, String providedChecksum) {
    final pack = _catalog[packId];
    if (pack == null) return false;

    if (pack.sha256Checksum != providedChecksum) {
      return false; // Corrupt download rejection
    }

    // Check if installing this exceeds storage threshold and trigger LRU prune
    if (computeDownloadedStorageMb() + pack.sizeMb > maxAllowedStorageMb) {
      pruneLruAudioPacks(reclaimTargetMb: pack.sizeMb);
    }

    pack.isDownloaded = true;
    pack.lastAccessedAt = DateTime.now();
    return true;
  }

  /// LRU eviction: deletes the least recently used optional packs when storage budget is exceeded.
  int pruneLruAudioPacks({required double reclaimTargetMb}) {
    int evictedCount = 0;
    double reclaimedSoFar = 0.0;

    final evictable = _catalog.values
        .where((p) => p.isDownloaded && p.packId != 'core_starter_pack')
        .toList()
      ..sort((a, b) => a.lastAccessedAt.compareTo(b.lastAccessedAt));

    for (final pack in evictable) {
      pack.isDownloaded = false;
      reclaimedSoFar += pack.sizeMb;
      evictedCount++;
      if (reclaimedSoFar >= reclaimTargetMb) break;
    }

    return evictedCount;
  }
}
