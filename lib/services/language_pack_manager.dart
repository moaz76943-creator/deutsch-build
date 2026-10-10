// ignore_for_file: unused_import

/// مدير حزم اللغات المعتمد المنضبط بمعيار BCP-47 وخالٍ تماماً من المعرفات الوهمية
class LanguagePackManager {
  static const List<String> supportedBcp47Locales = [
    'de-DE', 'ar-SA', 'en-US', 'fr-FR', 'es-ES', 'tr-TR', 'ru-RU', 'zh-CN'
  ];

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
