/// Noun class alignment between Swahili Bantu noun classes (Ngeli) and German genders (Genus).
class SwahiliNounClassBridge {
  final String swahiliNounClass; // e.g. M-WA (people), KI-VI (objects), M-MI (trees/plants)
  final String germanGenderAnalogy;
  final String pedagogicalExplanationSw;

  const SwahiliNounClassBridge({
    required this.swahiliNounClass,
    required this.germanGenderAnalogy,
    required this.pedagogicalExplanationSw,
  });
}

/// Deep localization profile for native Swahili (Kiswahili) speakers learning German.
class SwahiliDeepLocalizationProfile {
  static const String localeCode = 'sw';
  static const String languageName = 'Kiswahili (Swahili)';
  static const bool isRtl = false;
  static const String defaultWordOrder = 'SVO';

  static const List<SwahiliNounClassBridge> nounClassBridges = [
    SwahiliNounClassBridge(
      swahiliNounClass: 'Ngeli ya M-WA (Watu)',
      germanGenderAnalogy: 'Maskulin / Feminin kulingana na jinsia ya kibinadamu (der Mann, die Frau)',
      pedagogicalExplanationSw: 'Katika Kijerumani, watu hufuata jinsia halisi ya kibaolojia kama ilivyo katika ngeli ya M-WA ya Kiswahili.',
    ),
    SwahiliNounClassBridge(
      swahiliNounClass: 'Ngeli ya KI-VI (Vitu vidogo na ala)',
      germanGenderAnalogy: 'Neutrum (das Buch, das Instrument)',
      pedagogicalExplanationSw: 'Vitu vingi visivyo na uhai huchukua kiwakilishi cha kati "das" (Neutrum).',
    ),
  ];

  /// Shared SVO word order validation between Swahili and German main clauses.
  static bool hasSharedSvoOrder() => true;
}
