import 'package:flutter/widgets.dart' show TextDirection;
import 'database_service.dart';

/// BCP-47 metadata for up to 100 target languages.
/// Registration is not proof that a TTS voice or offline content pack exists.
class LanguagePackManager {
  static const Map<String, String> ttsLocales = {
    'af': 'af-ZA',
    'sq': 'sq-AL',
    'am': 'am-ET',
    'ar': 'ar-SA',
    'hy': 'hy-AM',
    'as': 'as-IN',
    'az': 'az-AZ',
    'eu': 'eu-ES',
    'be': 'be-BY',
    'bn': 'bn-BD',
    'bs': 'bs-BA',
    'bg': 'bg-BG',
    'my': 'my-MM',
    'ca': 'ca-ES',
    'ceb': 'ceb-PH',
    'zh': 'zh-CN',
    'hr': 'hr-HR',
    'cs': 'cs-CZ',
    'da': 'da-DK',
    'nl': 'nl-NL',
    'en': 'en-US',
    'eo': 'eo-001',
    'et': 'et-EE',
    'fil': 'fil-PH',
    'fi': 'fi-FI',
    'fr': 'fr-FR',
    'gl': 'gl-ES',
    'ka': 'ka-GE',
    'de': 'de-DE',
    'el': 'el-GR',
    'gu': 'gu-IN',
    'ht': 'ht-HT',
    'ha': 'ha-NG',
    'he': 'he-IL',
    'hi': 'hi-IN',
    'hu': 'hu-HU',
    'is': 'is-IS',
    'ig': 'ig-NG',
    'id': 'id-ID',
    'ga': 'ga-IE',
    'it': 'it-IT',
    'ja': 'ja-JP',
    'jv': 'jv-ID',
    'kn': 'kn-IN',
    'kk': 'kk-KZ',
    'km': 'km-KH',
    'ko': 'ko-KR',
    'ku': 'ku-TR',
    'ky': 'ky-KG',
    'lo': 'lo-LA',
    'la': 'la-VA',
    'lv': 'lv-LV',
    'lt': 'lt-LT',
    'mk': 'mk-MK',
    'mg': 'mg-MG',
    'ms': 'ms-MY',
    'ml': 'ml-IN',
    'mt': 'mt-MT',
    'mi': 'mi-NZ',
    'mr': 'mr-IN',
    'mn': 'mn-MN',
    'ne': 'ne-NP',
    'nb': 'nb-NO',
    'or': 'or-IN',
    'ps': 'ps-AF',
    'fa': 'fa-IR',
    'pl': 'pl-PL',
    'pt': 'pt-BR',
    'pa': 'pa-IN',
    'ro': 'ro-RO',
    'ru': 'ru-RU',
    'sm': 'sm-WS',
    'gd': 'gd-GB',
    'sr': 'sr-RS',
    'st': 'st-LS',
    'sn': 'sn-ZW',
    'sd': 'sd-PK',
    'si': 'si-LK',
    'sk': 'sk-SK',
    'sl': 'sl-SI',
    'so': 'so-SO',
    'es': 'es-ES',
    'su': 'su-ID',
    'sw': 'sw-KE',
    'sv': 'sv-SE',
    'tg': 'tg-TJ',
    'ta': 'ta-IN',
    'te': 'te-IN',
    'th': 'th-TH',
    'ti': 'ti-ET',
    'tr': 'tr-TR',
    'uk': 'uk-UA',
    'ur': 'ur-PK',
    'uz': 'uz-UZ',
    'vi': 'vi-VN',
    'cy': 'cy-GB',
    'xh': 'xh-ZA',
    'yi': 'yi-001',
    'yo': 'yo-NG',
    'zu': 'zu-ZA',
  };

  static final List<String> supportedLanguageCodes =
      List<String>.unmodifiable(ttsLocales.keys);

  static const List<String> supportedBcp47Locales = [
    'af-ZA', 'sq-AL', 'am-ET', 'ar-SA', 'hy-AM',
    'as-IN', 'az-AZ', 'eu-ES', 'be-BY', 'bn-BD',
    'bs-BA', 'bg-BG', 'my-MM', 'ca-ES', 'ceb-PH',
    'zh-CN', 'hr-HR', 'cs-CZ', 'da-DK', 'nl-NL',
    'en-US', 'eo-001', 'et-EE', 'fil-PH', 'fi-FI',
    'fr-FR', 'gl-ES', 'ka-GE', 'de-DE', 'el-GR',
    'gu-IN', 'ht-HT', 'ha-NG', 'he-IL', 'hi-IN',
    'hu-HU', 'is-IS', 'ig-NG', 'id-ID', 'ga-IE',
    'it-IT', 'ja-JP', 'jv-ID', 'kn-IN', 'kk-KZ',
    'km-KH', 'ko-KR', 'ku-TR', 'ky-KG', 'lo-LA',
    'la-VA', 'lv-LV', 'lt-LT', 'mk-MK', 'mg-MG',
    'ms-MY', 'ml-IN', 'mt-MT', 'mi-NZ', 'mr-IN',
    'mn-MN', 'ne-NP', 'nb-NO', 'or-IN', 'ps-AF',
    'fa-IR', 'pl-PL', 'pt-BR', 'pa-IN', 'ro-RO',
    'ru-RU', 'sm-WS', 'gd-GB', 'sr-RS', 'st-LS',
    'sn-ZW', 'sd-PK', 'si-LK', 'sk-SK', 'sl-SI',
    'so-SO', 'es-ES', 'su-ID', 'sw-KE', 'sv-SE',
    'tg-TJ', 'ta-IN', 'te-IN', 'th-TH', 'ti-ET',
    'tr-TR', 'uk-UA', 'ur-PK', 'uz-UZ', 'vi-VN',
    'cy-GB', 'xh-ZA', 'yi-001', 'yo-NG', 'zu-ZA',
  ];

  static const Map<String, String> _aliases = {
    'iw': 'he',
    'in': 'id',
    'ji': 'yi',
    'jw': 'jv',
    'no': 'nb',
    'tl': 'fil',
  };

  static const Set<String> _rtlLanguages = {
    'ar', 'he', 'fa', 'ur', 'ps', 'sd', 'yi',
  };

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

  /// The base language and standard locale are resolved without falling back
  /// to an unrelated language such as English.
  static String resolveTtsLocale(String languageCode) {
    final normalized = languageCode.trim().replaceAll('_', '-');
    if (normalized.isEmpty) return '';
    final parts = normalized.split('-');
    if (parts.any((part) => part.isEmpty)) return '';

    final rawLanguage = parts.first.toLowerCase();
    final language = _aliases[rawLanguage] ?? rawLanguage;
    final defaultLocale = ttsLocales[language];
    if (defaultLocale == null) return '';
    if (parts.length == 1) return defaultLocale;

    String? script;
    String? region;
    for (final part in parts.skip(1)) {
      if (script == null && RegExp(r'^[a-zA-Z]{4}$').hasMatch(part)) {
        script = part.substring(0, 1).toUpperCase() +
            part.substring(1).toLowerCase();
      } else if (region == null &&
          (RegExp(r'^[a-zA-Z]{2}$').hasMatch(part) ||
              RegExp(r'^[0-9]{3}$').hasMatch(part))) {
        region = part.toUpperCase();
      }
    }

    // Many system TTS engines use zh-CN / zh-TW rather than a script-only tag.
    if (language == 'zh' && region == null && script == 'Hant') {
      return 'zh-TW';
    }
    if (language == 'zh' && region == null && script == 'Hans') {
      return 'zh-CN';
    }
    if (region == null) return defaultLocale;
    if (script != null) return '$language-$script-$region';
    return '$language-$region';
  }

  /// Instance-facing contracts for consumers/screens.
  String getTtsLocale(String languageCode) => resolveTtsLocale(languageCode);

  List<String> get supportedLanguages => supportedLanguageCodes;

  bool isLanguageSupported(String languageCode) =>
      supportsLanguage(languageCode);

  static bool supportsLanguage(String languageCode) =>
      resolveTtsLocale(languageCode).isNotEmpty;

  static bool isLocaleSupported(String localeCode) =>
      supportsLanguage(localeCode);

  static bool isRtlLanguage(String languageCode) {
    final parts = languageCode.trim().replaceAll('_', '-').split('-');
    if (parts.isEmpty) return false;
    final language = _aliases[parts.first.toLowerCase()] ??
        parts.first.toLowerCase();
    // Kurdish, for example, may use either Arabic or Latin script.
    if (parts.any((part) => part.toLowerCase() == 'arab')) return true;
    if (parts.any((part) => part.toLowerCase() == 'latn')) return false;
    return _rtlLanguages.contains(language);
  }

  TextDirection textDirectionFor(String languageCode) =>
      isRtlLanguage(languageCode) ? TextDirection.rtl : TextDirection.ltr;

  static String getLanguageName(String localeCode) {
    final resolved = resolveTtsLocale(localeCode);
    return _languageNames[resolved] ?? localeCode;
  }

  String getLanguageNameInstance(String localeCode) =>
      getLanguageName(localeCode);

  /// Resolve a content identity independently of the TTS voice locale.
  /// A nondefault region or explicit script is never silently replaced by
  /// a different language pack (e.g. zh-Hant must not open zh).
  static String? resolveContentLanguageCode(String bcp47Locale) {
    final normalized = bcp47Locale.trim().toLowerCase().replaceAll('_', '-');
    if (!RegExp(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$')
        .hasMatch(normalized)) {
      return null;
    }
    final rawBase = normalized.split('-').first;
    final base = _aliases[rawBase] ?? rawBase;
    final defaultTtsLocale = ttsLocales[base]?.toLowerCase();
    if (defaultTtsLocale == null) return null;
    final contentTag = '$base${normalized.substring(rawBase.length)}';
    if (contentTag == base || contentTag == defaultTtsLocale) {
      return base;
    }
    return contentTag;
  }
  /// An offline pack is mounted only after SQLite opens read-only and passes
  /// DatabaseService's schema and integrity gates. No network fallback.
  static Future<bool> verifyAndMountOfflinePack(String bcp47Locale) async {
    final contentCode = resolveContentLanguageCode(bcp47Locale);
    if (contentCode == null) return false;
    try {
      await DatabaseService.instance.withContentDb<void>(
        contentCode, (db) async {},
      );
      return true;
    } catch (_) {
      // Missing, corrupt or incompatible packs must not be advertised as ready.
      return false;
    }
  }
}
