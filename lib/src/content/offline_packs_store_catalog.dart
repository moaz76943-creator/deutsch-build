/// Language pack metadata descriptor in the sovereign store.
class LanguagePackDescriptor {
  final String packId;
  final String targetLanguageCode;
  final String targetLanguageName;
  final String nativeLanguageCode;
  final double sizeMegabytes;
  final String minimumCefrLevel;
  final String maximumCefrLevel;
  final int totalWordCount;

  const LanguagePackDescriptor({
    required this.packId,
    required this.targetLanguageCode,
    required this.targetLanguageName,
    required this.nativeLanguageCode,
    required this.sizeMegabytes,
    required this.minimumCefrLevel,
    required this.maximumCefrLevel,
    required this.totalWordCount,
  });
}

/// Central catalog listing downloadable language packs in -offline-packs-store.
class OfflinePacksStoreCatalog {
  static const List<LanguagePackDescriptor> catalog = [
    LanguagePackDescriptor(
      packId: 'de_ar_master_v4',
      targetLanguageCode: 'de',
      targetLanguageName: 'Deutsch',
      nativeLanguageCode: 'ar',
      sizeMegabytes: 42.5,
      minimumCefrLevel: 'A1',
      maximumCefrLevel: 'C1',
      totalWordCount: 8500,
    ),
    LanguagePackDescriptor(
      packId: 'de_syc_heritage_v4',
      targetLanguageCode: 'de',
      targetLanguageName: 'Deutsch',
      nativeLanguageCode: 'syc',
      sizeMegabytes: 28.0,
      minimumCefrLevel: 'A1',
      maximumCefrLevel: 'B2',
      totalWordCount: 4200,
    ),
    LanguagePackDescriptor(
      packId: 'de_mt_semitic_v4',
      targetLanguageCode: 'de',
      targetLanguageName: 'Deutsch',
      nativeLanguageCode: 'mt',
      sizeMegabytes: 26.5,
      minimumCefrLevel: 'A1',
      maximumCefrLevel: 'B2',
      totalWordCount: 4000,
    ),
    LanguagePackDescriptor(
      packId: 'de_tr_community_v4',
      targetLanguageCode: 'de',
      targetLanguageName: 'Deutsch',
      nativeLanguageCode: 'tr',
      sizeMegabytes: 38.0,
      minimumCefrLevel: 'A1',
      maximumCefrLevel: 'C1',
      totalWordCount: 7500,
    ),
  ];

  /// Finds pack descriptor by target and native language codes.
  LanguagePackDescriptor? resolvePack(String target, String native) {
    for (final pack in catalog) {
      if (pack.targetLanguageCode.toLowerCase() == target.toLowerCase() &&
          pack.nativeLanguageCode.toLowerCase() == native.toLowerCase()) {
        return pack;
      }
    }
    return null;
  }
}
