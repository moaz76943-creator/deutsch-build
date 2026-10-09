class AudioFeedbackEngine {
  /// تحويل كود اللغة إلى معيار BCP-47 للمحركات الصوتية
  static String resolveLocaleTag(String langCode) {
    switch (langCode.toLowerCase().trim()) {
      case 'de': return 'de-DE';
      case 'en': return 'en-US';
      case 'fr': return 'fr-FR';
      case 'es': return 'es-ES';
      case 'it': return 'it-IT';
      case 'tr': return 'tr-TR';
      case 'ru': return 'ru-RU';
      case 'ar': return 'ar-SA';
      default: return '$langCode-${langCode.toUpperCase()}';
    }
  }

  static double getPitchForGender(String gender) {
    final g = gender.toLowerCase().trim();
    if (['der', 'le', 'el', 'il', 'm'].contains(g)) return 0.9;
    if (['die', 'la', 'f'].contains(g)) return 1.15;
    return 1.0;
  }

  static double getPitchForArticle(String article) => getPitchForGender(article);

  static double getRecommendedSpeed({required bool isSlowMode}) {
    return isSlowMode ? 0.75 : 1.0;
  }
}
