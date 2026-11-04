import 'package:flutter/widgets.dart';

import 'database_service.dart';

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

  /// BCP-47 tag used by TTS. Stateless, so both static and instance callers
  /// resolve the same catalog value.
  static String resolveTtsLocale(String code) => getTtsLocale(code);
  String getLanguageNameInstance(String localeCode) =>
      getLanguageName(localeCode);

  /// Registration does not imply an installed or production-ready pack.
  static bool isLocalesSupported(String localeCode) {
    final normalized = localeCode.trim().replaceAll('_', '-').toLowerCase();
    if (!RegExp(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$')
        .hasMatch(normalized)) {
      return false;
    }
    return supportedLanguages.contains(normalized.split('-').first);
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

  /// Opens the installed content database for [bcp47Locale].
  /// Returns false when the locale is unknown or the pack cannot be opened.
  /// A missing pack is not treated as mounted.
  static Future<bool> verifyAndMountOfflinePack(String bcp47Locale) async {
    final langCode = bcp47Locale.split('-').first.trim().toLowerCase();
    if (langCode.isEmpty) return false;
    final known = supportedLanguages.contains(langCode) ||
        supportedBcp47Locales.contains(bcp47Locale);
    if (!known) return false;
    try {
      final db = await DatabaseService.instance.getContentDb(langCode);
      if (!db.isOpen) return false;
      await db.rawQuery('SELECT 1');
      return true;
    } catch (_) {
      return false;
    }
  }

  // Instance delegates لتفادي أخطاء الاستدعاء عبر الكائنات
  List<String> get supportedLanguagesInstance => supportedLanguages;
  List<String> get supportedLanguagesList => supportedLanguages;
  List<String> get supportedLanguagesField => supportedLanguages;
}

extension LanguagePackManagerInstanceExt on LanguagePackManager {
  List<String> get supportedLanguages => LanguagePackManager.supportedLanguages;
  String getTtsLocale(String code) => LanguagePackManager.getTtsLocale(code);
  String resolveTtsLocale(String code) =>
      LanguagePackManager.resolveTtsLocale(code);
  bool isLanguagesSupported(String code) =>
      LanguagePackManager.isLanguagesSupported(code);
  TextDirection textDirectionFor(String code) =>
      LanguagePackManager.textDirectionFor(code);
  bool isRtlLanguage(String code) => LanguagePackManager.isRtlLanguage(code);
}
