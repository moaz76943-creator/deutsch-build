/// Validates and inventories packaged sovereign assets in release build.
class ReleaseAssetsManifest {
  final int totalProfilesCount;
  final bool hasEmbeddedDatabase;
  final bool hasAudioModels;
  final bool isProGuardConfigured;

  const ReleaseAssetsManifest({
    required this.totalProfilesCount,
    required this.hasEmbeddedDatabase,
    required this.hasAudioModels,
    required this.isProGuardConfigured,
  });

  bool get isReadyForPackaging =>
      totalProfilesCount >= 10 &&
      hasEmbeddedDatabase &&
      hasAudioModels &&
      isProGuardConfigured;

  Map<String, dynamic> toJson() => {
    'totalProfilesCount': totalProfilesCount,
    'hasEmbeddedDatabase': hasEmbeddedDatabase,
    'hasAudioModels': hasAudioModels,
    'isProGuardConfigured': isProGuardConfigured,
    'isReadyForPackaging': isReadyForPackaging,
  };
}
