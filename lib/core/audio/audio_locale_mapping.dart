class AudioLocaleMapping {
  /// Comprehensive 100-language BCP-47 TTS locale mapping
  static const Map<String, String> polyglotLocales = {
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
    'zu': 'zu-ZA',
  };

  /// Explicitly approved regional fallbacks mapping
  static const Map<String, String> approvedFallbacks = {
    'es-MX': 'es-ES',
    'es-US': 'es-ES',
    'fr-CA': 'fr-FR',
    'pt-BR': 'pt-PT',
    'en-GB': 'en-US',
    'en-AU': 'en-US',
    'en-CA': 'en-US',
    'en-IN': 'en-US',
  };

  /// Resolves the requested locale to a verified offline locale.
  /// Enforces strict matching or approved fallbacks.
  /// Never falls back silently to English or German unless explicitly requested.
  /// Returns null if no offline voice is available.
  static String? resolveOfflineCapability(
    String requestedLocale,
    List<String> availableOfflineLocales,
  ) {
    // 1. Try exact match
    if (availableOfflineLocales.contains(requestedLocale)) {
      return requestedLocale;
    }

    // 2. Try language-only exact match against available full locales
    // e.g. requested 'es', available 'es-ES'
    final requestedLanguage = requestedLocale.split('-')[0];
    for (final available in availableOfflineLocales) {
      if (available.startsWith('$requestedLanguage-') ||
          available == requestedLanguage) {
        // Must check if this available locale is the approved default for the language
        if (polyglotLocales[requestedLanguage] == available) {
          return available;
        }
      }
    }

    // 3. Try mapping from requested language code using polyglotLocales
    if (polyglotLocales.containsKey(requestedLanguage)) {
      final mappedLocale = polyglotLocales[requestedLanguage]!;
      if (availableOfflineLocales.contains(mappedLocale)) {
        return mappedLocale;
      }
    }

    // 4. Try approved fallbacks
    if (approvedFallbacks.containsKey(requestedLocale)) {
      final fallbackLocale = approvedFallbacks[requestedLocale]!;
      if (availableOfflineLocales.contains(fallbackLocale)) {
        return fallbackLocale;
      }
    }

    // 5. Check if the mapped locale from polyglotLocales has a fallback
    if (polyglotLocales.containsKey(requestedLanguage)) {
      final mappedLocale = polyglotLocales[requestedLanguage]!;
      if (approvedFallbacks.containsKey(mappedLocale)) {
        final fallbackLocale = approvedFallbacks[mappedLocale]!;
        if (availableOfflineLocales.contains(fallbackLocale)) {
          return fallbackLocale;
        }
      }
    }

    return null;
  }
}
