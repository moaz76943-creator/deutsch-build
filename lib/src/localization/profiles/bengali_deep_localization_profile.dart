/// Politeness honorific mapping between Bengali and German address pronouns.
class HonorificPronounMap {
  final String bengaliPronoun;
  final String bengaliFormalityLevel;
  final String germanEquivalent;
  final String usageExplanationBn;

  const HonorificPronounMap({
    required this.bengaliPronoun,
    required this.bengaliFormalityLevel,
    required this.germanEquivalent,
    required this.usageExplanationBn,
  });
}

/// Deep localization profile for native Bengali (Bangla) speakers learning German.
class BengaliDeepLocalizationProfile {
  static const String localeCode = 'bn';
  static const String languageName = 'বাংলা (Bengali)';
  static const bool isRtl = false;
  static const String defaultWordOrder = 'SOV';

  static const List<HonorificPronounMap> honorifics = [
    HonorificPronounMap(
      bengaliPronoun: 'আপনি (Apni)',
      bengaliFormalityLevel: 'Formal / Respectful',
      germanEquivalent: 'Sie (immer großgeschrieben)',
      usageExplanationBn: 'অপরিচিত ব্যক্তি, শিক্ষক এবং কর্মক্ষেত্রে আনুষ্ঠানিক যোগাযোগের জন্য ব্যবহৃত হয়।',
    ),
    HonorificPronounMap(
      bengaliPronoun: 'তুমি (Tumi) / তুই (Tui)',
      bengaliFormalityLevel: 'Informal / Familiar',
      germanEquivalent: 'du (Singular) / ihr (Plural)',
      usageExplanationBn: 'বন্ধু-বান্ধব, পরিবারের সদস্য এবং শিশুদের সাথে অনানুষ্ঠানিক কথা বলার জন্য।',
    ),
  ];

  /// Word order guidance addressing Bengali SOV to German V2 rule.
  static String getBengaliSyntacticGuidance() {
    return 'বাংলায় ক্রিয়া সাধারণত বাক্যের শেষে বসে (SOV), কিন্তু জার্মান প্রধান বাক্যে সমাপিকা ক্রিয়া সর্বদা ২য় স্থানে বসে (V2 Rule)।\n'
        'উদাহরণ: "আমি বই পড়ি" -> "Ich lese das Buch."';
  }
}
