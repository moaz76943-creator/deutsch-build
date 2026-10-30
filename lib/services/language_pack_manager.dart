import 'package:flutter/widgets.dart';

class LanguagePackManager {
  static const List<String> supportedBcp47Locales = [
    'de-DE',
    'ar-SA',
    'en-US',
    'fr-FR',
    'es-ES',
    'tr-TR',
    'ru-RU',
    'zh-CN'
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

  static List<String> get supportedLanguages => [
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
        'nl',
        'no',
        'pl',
        'pt',
        'ro',
        'ru',
        'sk',
        'sl',
        'sq',
        'sr',
        'sv',
        'sw',
        'ta',
        'te',
        'th',
        'tr',
        'uk',
        'ur',
        'vi',
        'zh'
      ];

  static String getTtsLocale(String languageCode) => languageCode;
  String getLanguageNameInstance(String localeCode) =>
      getLanguageName(localeCode);

  static bool isLocalesSupported(String localeCode) {
    if (localeCode.isEmpty) return false;
    return true;
  }

  static bool isLanguagesSupported(String languageCode) =>
      isLocalesSupported(languageCode);
  bool isLanguageSupported(String languageCode) =>
      isLocalesSupported(languageCode);

  static bool isRtlLanguage(String code) {
    final lower = code.toLowerCase();
    return lower.startsWith('ar') ||
        lower.startsWith('he') ||
        lower.startsWith('fa') ||
        lower.startsWith('ur');
  }

  static TextDirection textDirectionFor(String code) {
    return isRtlLanguage(code) ? TextDirection.rtl : TextDirection.ltr;
  }

  // Instance delegates لتفادي أخطاء الاستدعاء عبر الكائنات
  List<String> get supportedLanguagesInstance => supportedLanguages;
  List<String> get supportedLanguagesList => supportedLanguages;
  List<String> get supportedLanguagesField => supportedLanguages;
  String resolveTtsLocale(String code) => getTtsLocale(code);
}

extension LanguagePackManagerInstanceExt on LanguagePackManager {
  List<String> get supportedLanguages => LanguagePackManager.supportedLanguages;
  String getTtsLocale(String code) => LanguagePackManager.getTtsLocale(code);
  bool isLanguagesSupported(String code) =>
      LanguagePackManager.isLanguagesSupported(code);
  TextDirection textDirectionFor(String code) =>
      LanguagePackManager.textDirectionFor(code);
  bool isRtlLanguage(String code) => LanguagePackManager.isRtlLanguage(code);
}
