import 'package:flutter_tts/flutter_tts.dart';

class AudioTtsService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isInitialized = false;

  /// خريطة كاملة لمحددات اللهجات لـ 100 لغة وفق معايير BCP 47
  static final Map<String, String> languageLocales = {
    'af': 'af-ZA', 'am': 'am-ET', 'ar': 'ar-SA', 'az': 'az-AZ', 'be': 'be-BY',
    'bg': 'bg-BG', 'bn': 'bn-BD', 'bs': 'bs-BA', 'ca': 'ca-ES', 'cs': 'cs-CZ',
    'cy': 'cy-GB', 'da': 'da-DK', 'de': 'de-DE', 'el': 'el-GR', 'en': 'en-US',
    'eo': 'eo',    'es': 'es-ES', 'et': 'et-EE', 'eu': 'eu-ES', 'fa': 'fa-IR',
    'fi': 'fi-FI', 'fil': 'fil-PH','fr': 'fr-FR', 'ga': 'ga-IE', 'gl': 'gl-ES',
    'gu': 'gu-IN', 'he': 'he-IL', 'hi': 'hi-IN', 'hr': 'hr-HR', 'ht': 'ht-HT',
    'hu': 'hu-HU', 'hy': 'hy-AM', 'id': 'id-ID', 'is': 'is-IS', 'it': 'it-IT',
    'ja': 'ja-JP', 'jv': 'jv-ID', 'ka': 'ka-GE', 'kk': 'kk-KZ', 'km': 'km-KH',
    'kn': 'kn-IN', 'ko': 'ko-KR', 'ku': 'ku-TR', 'ky': 'ky-KG', 'la': 'la',
    'lb': 'lb-LU', 'lo': 'lo-LA', 'lt': 'lt-LT', 'lv': 'lv-LV', 'mg': 'mg-MG',
    'mi': 'mi-NZ', 'mk': 'mk-MK', 'ml': 'ml-IN', 'mn': 'mn-MN', 'mr': 'mr-IN',
    'ms': 'ms-MY', 'mt': 'mt-MT', 'my': 'my-MM', 'ne': 'ne-NP', 'nl': 'nl-NL',
    'no': 'nb-NO', 'ny': 'ny-MW', 'or': 'or-IN', 'pa': 'pa-IN', 'pl': 'pl-PL',
    'ps': 'ps-AF', 'pt': 'pt-BR', 'ro': 'ro-RO', 'ru': 'ru-RU', 'rw': 'rw-RW',
    'si': 'si-LK', 'sk': 'sk-SK', 'sl': 'sl-SI', 'sm': 'sm-WS', 'sn': 'sn-ZW',
    'so': 'so-SO', 'sq': 'sq-AL', 'sr': 'sr-RS', 'st': 'st-ZA', 'su': 'su-ID',
    'sv': 'sv-SE', 'sw': 'sw-KE', 'ta': 'ta-IN', 'te': 'te-IN', 'tg': 'tg-TJ',
    'th': 'th-TH', 'ti': 'ti-ET', 'tk': 'tk-TM', 'tl': 'fil-PH','tr': 'tr-TR',
    'tt': 'tt-RU', 'ug': 'ug-CN', 'uk': 'uk-UA', 'ur': 'ur-PK', 'uz': 'uz-UZ',
    'vi': 'vi-VN', 'xh': 'xh-ZA', 'yi': 'yi',    'yo': 'yo-NG', 'zh': 'zh-CN',
    'zu': 'zu-ZA'
  };

  static Future<void> init() async {
    if (_isInitialized) return;
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _isInitialized = true;
  }

  static Future<void> speak({
    required String text,
    required String languageCode,
  }) async {
    await init();
    final locale = languageLocales[languageCode] ?? 'en-US';
    final isAvailable = await _tts.isLanguageAvailable(locale);

    if (isAvailable == 1 || isAvailable == true) {
      await _tts.setLanguage(locale);
    } else {
      await _tts.setLanguage('en-US');
    }

    await _tts.stop();
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }
}
