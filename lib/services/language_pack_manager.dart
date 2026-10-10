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

    static List<String> get supportedLanguages => const [
    'af',
    'am',
    'ar',
    'az',
    'be',
    'bg',
    'bn',
    'bs',
    'ca',
    'cs',
    'cy',
    'da',
    'de',
    'el',
    'en',
    'eo',
    'es',
    'et',
    'eu',
    'fa',
    'fi',
    'fil',
    'fr',
    'ga',
    'gl',
    'gu',
    'ha',
    'he',
    'hi',
    'hr',
    'hu',
    'hy',
    'id',
    'ig',
    'is',
    'it',
    'ja',
    'jv',
    'ka',
    'kk',
    'km',
    'kn',
    'ko',
    'ku',
    'ky',
    'la',
    'lb',
    'lo',
    'lt',
    'lv',
    'mg',
    'mk',
    'ml',
    'mn',
    'mr',
    'ms',
    'mt',
    'my',
    'ne',
    'nl',
    'no',
    'ny',
    'om',
    'pa',
    'pl',
    'ps',
    'pt',
    'ro',
    'ru',
    'rw',
    'sd',
    'si',
    'sk',
    'sl',
    'sn',
    'so',
    'sq',
    'sr',
    'st',
    'su',
    'sv',
    'sw',
    'ta',
    'te',
    'tg',
    'th',
    'ti',
    'tk',
    'tl',
    'tr',
    'tt',
    'ug',
    'uk',
    'ur',
    'uz',
    'vi',
    'wo',
    'xh',
    'yo',
    'zu'
  ];

  static String getTtsLocale(String code) {
    switch (code.toLowerCase()) {
      case 'ar': return 'ar-SA';
      case 'en': return 'en-US';
      case 'fr': return 'fr-FR';
      case 'es': return 'es-ES';
      case 'tr': return 'tr-TR';
      case 'ru': return 'ru-RU';
      case 'de': return 'de-DE';
      default: return 'de-DE';
    }
  }

}
