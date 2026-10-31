/// Definite article comparison between Somali suffixed articles and German prefix articles.
class SomaliArticleBridge {
  final String somaliSuffix; // -ka, -ta, -da, -ga
  final String germanArticle; // der, die, das
  final String pedagogicalNoteSo;

  const SomaliArticleBridge({
    required this.somaliSuffix,
    required this.germanArticle,
    required this.pedagogicalNoteSo,
  });
}

/// Deep localization profile for native Somali (Af-Soomaali) speakers learning German.
class SomaliDeepLocalizationProfile {
  static const String localeCode = 'so';
  static const String languageName = 'Af-Soomaali (Somali)';
  static const bool isRtl = false;
  static const String defaultWordOrder = 'SOV';

  static const List<SomaliArticleBridge> articleBridges = [
    SomaliArticleBridge(
      somaliSuffix: '-ka / -ga (Lab - Masculine)',
      germanArticle: 'der (Maskulin)',
      pedagogicalNoteSo: 'Af-Soomaaliga qodobka qeexa waxa lagu daraa gadaal (tusaale: buug -> buugga), laakiin Jarmalka waxa la mariyaa horteeda (das Buch).',
    ),
    SomaliArticleBridge(
      somaliSuffix: '-ta / -da (Dheddig - Feminine)',
      germanArticle: 'die (Feminin)',
      pedagogicalNoteSo: 'Magacyada dheddiga ee Soomaaliga ee qaata (-ta) waxa u dhigma xarafka (die) ee Jarmalka.',
    ),
  ];

  /// Word order pedagogical guidance for Somali learners.
  static String getSomaliWordOrderGuidance() {
    return 'Af-Soomaaliga ficilku wuxuu yimaadaa xagga dambe (SOV), laakiin luuqadda Jarmalka ficilku mar kasta wuxuu fadhiyaa booska 2-aad (V2 Rule).\n'
        'Tusaale: "Anigu maanta tufaax baan cunayaa" -> "Ich esse heute einen Apfel."';
  }
}
