/// Storage breakdown between text content database and optional high-fidelity audio chunks.
class StorageBreakdown {
  final String packId;
  final double textDatabaseMb;
  final double optionalAudioMb;
  final bool isAudioDownloaded;
  final double totalDiskFootprintMb;

  const StorageBreakdown({
    required this.packId,
    required this.textDatabaseMb,
    required this.optionalAudioMb,
    required this.isAudioDownloaded,
    required this.totalDiskFootprintMb,
  });
}

/// Enables lean text-first installations with on-demand audio pack downloading for space-constrained devices.
class DynamicAudioPackStorageManager {
  /// Calculates storage allocation and enables modular audio management.
  StorageBreakdown calculateFootprint({
    required String packId,
    required double baseTextDbMb,
    required double audioPackMb,
    required bool includeAudio,
  }) {
    final total = includeAudio ? (baseTextDbMb + audioPackMb) : baseTextDbMb;

    return StorageBreakdown(
      packId: packId,
      textDatabaseMb: baseTextDbMb,
      optionalAudioMb: audioPackMb,
      isAudioDownloaded: includeAudio,
      totalDiskFootprintMb: double.parse(total.toStringAsFixed(1)),
    );
  }

  /// Verifies if device has sufficient storage buffer before audio pack installation.
  bool canSafelyInstallAudio({required double freeDiskSpaceMb, required double audioPackMb}) {
    // Keep at least 250MB free buffer for OS operations
    return (freeDiskSpaceMb - audioPackMb) >= 250.0;
  }
}
