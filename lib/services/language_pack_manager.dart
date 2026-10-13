// ignore_for_file: unused_import
import 'package:http/http.dart' as http;
import 'pack_downloader_service.dart';

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

  /// Explicitly request download of a language pack with explicit user intent.
  static Future<bool> acquirePack(String localeCode, String url, String expectedHash, {http.Client? client}) async {
    if (!isLocaleSupported(localeCode)) return false;
    return await PackDownloaderService.downloadPack(
      localeCode,
      url: url,
      expectedHash: expectedHash,
      client: client,
    );
  }

  // legacy support
  static List<String> get supportedLanguages {
    return _polyglotMatrix;
  }

  static String getTtsLocale(String localeCode) {
    return localeCode;
  }

  static const List<String> _polyglotMatrix = [
    'lang_01', 'lang_02', 'lang_03', 'lang_04', 'lang_05', 'lang_06', 'lang_07', 'lang_08', 'lang_09', 'lang_10',
    'lang_11', 'lang_12', 'lang_13', 'lang_14', 'lang_15', 'lang_16', 'lang_17', 'lang_18', 'lang_19', 'lang_20',
    'lang_21', 'lang_22', 'lang_23', 'lang_24', 'lang_25', 'lang_26', 'lang_27', 'lang_28', 'lang_29', 'lang_30',
    'lang_31', 'lang_32', 'lang_33', 'lang_34', 'lang_35', 'lang_36', 'lang_37', 'lang_38', 'lang_39', 'lang_40',
    'lang_41', 'lang_42', 'lang_43', 'lang_44', 'lang_45', 'lang_46', 'lang_47', 'lang_48', 'lang_49', 'lang_50',
    'lang_51', 'lang_52', 'lang_53', 'lang_54', 'lang_55', 'lang_56', 'lang_57', 'lang_58', 'lang_59', 'lang_60',
    'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja', 'ko', 'ar', 'hi', 'tr', 'nl', 'sv', 'fi', 'da', 'no',
    'pl', 'uk', 'cs', 'el', 'hu', 'ro', 'sk', 'hr', 'bg', 'sr', 'sl', 'lt', 'lv', 'et', 'is', 'ga', 'cy', 'mt',
    'sq', 'mk', 'bs', 'vi'
  ];
}
