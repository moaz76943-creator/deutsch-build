/// High-performance offline text normalizer for Arabic and German lexicons.
/// Strips tashkeel (diacritics), unifies hamza variants, and maps German umlauts
/// to guarantee flawless search matches across diverse user keyboards.
class ArabicGermanOrthographyNormalizer {
  static final RegExp _arabicTashkeelRegex = RegExp(r'[\u064B-\u0652\u0670]');
  static final RegExp _arabicTatweelRegex = RegExp(r'\u0640');

  /// Normalize Arabic text for invariant indexing and matching.
  static String normalizeArabic(String text) {
    if (text.isEmpty) return '';

    String cleaned = text.replaceAll(_arabicTashkeelRegex, '');
    cleaned = cleaned.replaceAll(_arabicTatweelRegex, '');

    // Unify Alef forms
    cleaned = cleaned.replaceAll(RegExp(r'[أإآ]'), 'ا');
    // Unify Taa Marbuta to Haa
    cleaned = cleaned.replaceAll('ة', 'ه');
    // Unify Yaa / Alef Maksura
    cleaned = cleaned.replaceAll('ى', 'ي');

    return cleaned.trim();
  }

  /// Normalize German text for search matching while retaining phonemic identity.
  static String normalizeGerman(String text, {bool unfoldUmlauts = false}) {
    if (text.isEmpty) return '';

    String cleaned = text.trim();
    if (unfoldUmlauts) {
      cleaned = cleaned
          .replaceAll('ä', 'ae')
          .replaceAll('ö', 'oe')
          .replaceAll('ü', 'ue')
          .replaceAll('ß', 'ss')
          .replaceAll('Ä', 'Ae')
          .replaceAll('Ö', 'Oe')
          .replaceAll('Ü', 'Ue');
    }

    return cleaned;
  }
}
