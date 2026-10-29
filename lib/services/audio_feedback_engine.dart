class AudioFeedbackEngine {
  /// Comprehensive 100-language BCP-47 TTS locale mapping
  static const Map<String, String> _polyglotLocales = {
    'af': 'af-ZA',
    'am': 'am-ET',
    'ar': 'ar-SA',
    'az': 'az-AZ',
    'be': 'be-BY',
    'bg': 'bg-BG',
    'bn': 'bn-BD',
    'bs': 'bs-BA',
    'ca': 'ca-ES',
    'ceb': 'ceb-PH',
    'cs': 'cs-CZ',
    'cy': 'cy-GB',
    'da': 'da-DK',
    'de': 'de-DE',
    'el': 'el-GR',
    'en': 'en-US',
    'eo': 'eo',
    'es': 'es-ES',
    'et': 'et-EE',
    'eu': 'eu-ES',
    'fa': 'fa-IR',
    'fi': 'fi-FI',
    'fil': 'fil-PH',
    'fr': 'fr-FR',
    'ga': 'ga-IE',
    'gl': 'gl-ES',
    'gu': 'gu-IN',
    'ha': 'ha-NG',
    'he': 'he-IL',
    'hi': 'hi-IN',
    'hr': 'hr-HR',
    'ht': 'ht-HT',
    'hu': 'hu-HU',
    'hy': 'hy-AM',
    'id': 'id-ID',
    'ig': 'ig-NG',
    'is': 'is-IS',
    'it': 'it-IT',
    'iw': 'he-IL',
    'ja': 'ja-JP',
    'jv': 'jv-ID',
    'ka': 'ka-GE',
    'kk': 'kk-KZ',
    'km': 'km-KH',
    'kn': 'kn-IN',
    'ko': 'ko-KR',
    'ku': 'ku-TR',
    'ky': 'ky-KG',
    'la': 'la',
    'lb': 'lb-LU',
    'lo': 'lo-LA',
    'lt': 'lt-LT',
    'lv': 'lv-LV',
    'mg': 'mg-MG',
    'mi': 'mi-NZ',
    'mk': 'mk-MK',
    'ml': 'ml-IN',
    'mn': 'mn-MN',
    'mr': 'mr-IN',
    'ms': 'ms-MY',
    'mt': 'mt-MT',
    'my': 'my-MM',
    'ne': 'ne-NP',
    'nl': 'nl-NL',
    'no': 'nb-NO',
    'nb': 'nb-NO',
    'nn': 'nn-NO',
    'ny': 'ny-MW',
    'pa': 'pa-IN',
    'pl': 'pl-PL',
    'ps': 'ps-AF',
    'pt': 'pt-PT',
    'ro': 'ro-RO',
    'ru': 'ru-RU',
    'rw': 'rw-RW',
    'sd': 'sd-PK',
    'si': 'si-LK',
    'sk': 'sk-SK',
    'sl': 'sl-SI',
    'sm': 'sm-WS',
    'sn': 'sn-ZW',
    'so': 'so-SO',
    'sq': 'sq-AL',
    'sr': 'sr-RS',
    'st': 'st-ZA',
    'su': 'su-ID',
    'sv': 'sv-SE',
    'sw': 'sw-TZ',
    'ta': 'ta-IN',
    'te': 'te-IN',
    'tg': 'tg-TJ',
    'th': 'th-TH',
    'tl': 'fil-PH',
    'tr': 'tr-TR',
    'tt': 'tt-RU',
    'ug': 'ug-CN',
    'uk': 'uk-UA',
    'ur': 'ur-PK',
    'uz': 'uz-UZ',
    'vi': 'vi-VN',
    'xh': 'xh-ZA',
    'yi': 'yi',
    'yo': 'yo-NG',
    'zh': 'zh-CN',
    'zu': 'zu-ZA'
  };

  /// Backward compatible and polyglot-ready locale resolver
  static String resolveLocaleTag(String langCode) {
    final clean = langCode.toLowerCase().trim();
    if (_polyglotLocales.containsKey(clean)) {
      return _polyglotLocales[clean]!;
    }
    if (clean.contains('-')) {
      return clean;
    }
    return '$clean-${clean.toUpperCase()}';
  }

  static double getPitchForGender(String gender) {
    final g = gender.toLowerCase().trim();
    if (['der', 'le', 'el', 'il', 'm'].contains(g)) return 0.9;
    if (['die', 'la', 'f'].contains(g)) return 1.15;
    return 1.0;
  }

  static double getPitchForArticle(String article) =>
      getPitchForGender(article);

  static double getRecommendedSpeed({required bool isSlowMode}) {
    return isSlowMode ? 0.75 : 1.0;
  }
}
