// ignore_for_file: unused_import

class LanguagePackManager {
  static const List<String> supportedBcp47Locales = [
    'de-DE', 'ar-SA', 'en-US', 'fr-FR', 'es-ES', 'tr-TR', 'ru-RU', 'zh-CN'
  ];

  static const Map<String, String> _languageNames = {
    'de-DE': 'الألمانية (Deutsch)',
    'ar-SA': 'العربية',
    'en-US': 'الإنجليزية (English)',
    'fr-FR': 'الفرنسية (Français)',
    'es-ES': 'الإسبانية (Español)',
    'tr-TR': 'التركية (Türkçe)',
    'ru-RU': 'الروسية (Русский)',
    'zh-CN': 'الصينية (中文)',
  };

  static String getLanguageName(String localeCode) {
    return _languageNames[localeCode] ?? localeCode;
  }

  // دعم استدعاء الدالة سواء كـ static أو من خلال كائن instance
  String getLanguageNameInstance(String localeCode) => getLanguageName(localeCode);

  static bool isLocaleSupported(String localeCode) {
    if (localeCode.isEmpty) return false;
    if (localeCode.startsWith('he') || localeCode.startsWith('iw')) return false;
    return supportedBcp47Locales.contains(localeCode);
  }

  static Future<bool> verifyAndMountOfflinePack(String bcp47Locale) async {
    if (!isLocaleSupported(bcp47Locale)) return false;
    return true;
  }
}
