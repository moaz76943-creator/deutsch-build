/// Deep localization profile for native Urdu speakers learning German syntax and morphology.
class UrduDeepLocalizationProfile {
  static const String localeCode = 'ur';
  static const String languageName = 'اردو (Urdu)';
  static const bool isRtl = true;
  static const String preferredFont = 'NotoNastaliqUrdu';
  static const String defaultWordOrder = 'SOV';

  /// Maps German cases to Urdu postposition markers (Alamat-e-Izafat / Karaka).
  static const Map<String, String> caseEquivalentsUrdu = {
    'Nominative (der/die/das)': 'فاعلی حالت (فاعل - جملے کا موضوع)',
    'Accusative (den/die/das)': 'مفعولی حالت (علامتِ مفعول: کو / ne/ko)',
    'Dative (dem/der/dem)': 'حالتِ جر (علامتِ مفعولِ ثانی: کے لیے / پر)',
    'Genitive (des/der/des)': 'اضافی حالت (علامتِ اضافت: کا / کے / کی)',
  };

  /// Syntactic guidance addressing the SOV (Urdu) to SVO/V2 (German) word order shift.
  static String getWordOrderGuidance() {
    return 'اردو میں فعل عام طور پر جملے کے آخر میں آتا ہے (SOV)، جبکہ جرمن زبان کے مرکزی جملے میں '
        'فعل لازماً دوسرے مقام پر رہتا ہے (V2 Rule)۔\n'
        'مثال: "میں کتاب پڑھتا ہوں" -> "Ich lese das Buch." (نہ کہ: Ich das Buch lese!)';
  }
}
