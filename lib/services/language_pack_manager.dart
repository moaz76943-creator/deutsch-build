class LanguagePackManager {
  static final List<String> supportedLanguages = [
    'de', 'en', 'ar', 'es', 'fr', 'it'
  ];

  static String getLanguageName(String code) {
    switch (code) {
      case 'de': return 'German (Deutsch)';
      case 'ar': return 'العربية';
      case 'es': return 'Spanish';
      case 'fr': return 'French';
      case 'it': return 'Italian';
      default: return code;
    }
  }

  static String getTtsLocale(String code) {
    switch (code) {
      case 'de': return 'de-DE';
      case 'ar': return 'ar-SA';
      case 'es': return 'es-ES';
      case 'fr': return 'fr-FR';
      case 'it': return 'it-IT';
      default: return 'en-US';
    }
  }

  static Future<bool> verifyAndMountOfflinePack(String code) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
}
