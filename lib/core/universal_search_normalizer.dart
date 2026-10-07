class UniversalSearchNormalizer {
  /// تسوية النصوص وإزالة العلامات الصوتية والتشكيل لجميع اللغات
  static String normalize(String text) {
    String normalized = text.toLowerCase().trim();

    // إزالة الحركات والتشكيل العربي
    final arabicDiacritics = RegExp(r'[\u064B-\u065F\u0670]');
    normalized = normalized.replaceAll(arabicDiacritics, '');
    normalized = normalized.replaceAll(RegExp(r'[أإآ]'), 'ا');
    normalized = normalized.replaceAll('ة', 'ه');
    normalized = normalized.replaceAll('ى', 'ي');

    // تسوية الحروف اللاتينية والأوروبية الخاصة
    const replacements = {
      'ä': 'a', 'ö': 'o', 'ü': 'u', 'ß': 'ss', // ألماني
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'ç': 'c', // فرنسي
      'ñ': 'n', 'á': 'a', 'í': 'i', 'ó': 'o', 'ú': 'u', // إسباني
      'ğ': 'g', 'ş': 's', 'ı': 'i', 'İ': 'i'             // تركي
    };

    replacements.forEach((key, val) {
      normalized = normalized.replaceAll(key, val);
    });

    return normalized;
  }

  static bool matches(String source, String query) {
    if (query.trim().isEmpty) return true;
    final cleanSource = normalize(source);
    final cleanQuery = normalize(query);
    return cleanSource.contains(cleanQuery);
  }
}
