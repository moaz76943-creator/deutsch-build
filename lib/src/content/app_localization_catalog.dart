/// Localized UI string map holding translations for primary platform controls.
class AppLocalizationCatalog {
  static const Map<String, Map<String, String>> translations = {
    'de': {
      'app_title': 'Polyglot Souverän',
      'start_practice': 'Übung starten',
      'review_due': 'Wiederholung fällig',
      'dialogue_mode': 'Freies Gespräch',
      'privacy_notice': '100% Offline & Privat',
      'settings': 'Einstellungen',
    },
    'ar': {
      'app_title': 'بوليجلوت السيادي',
      'start_practice': 'ابدأ التدريب',
      'review_due': 'مراجعات مستحقة',
      'dialogue_mode': 'محادثة حرة',
      'privacy_notice': '١٠٠٪ دون إنترنت وبخصوصية تامة',
      'settings': 'الإعدادات',
    },
    'en': {
      'app_title': 'Polyglot Sovereign',
      'start_practice': 'Start Practice',
      'review_due': 'Reviews Due',
      'dialogue_mode': 'Free Conversation',
      'privacy_notice': '100% Offline & Sovereign',
      'settings': 'Settings',
    },
    'syc': {
      'app_title': 'ܦܘܠܝܓܠܘܛ ܚܐܪܐ',
      'start_practice': 'ܫܪܝ ܕܘܪܫܐ',
      'review_due': 'ܬܢܝܬܐ ܕܙܕܩܐ',
      'dialogue_mode': 'ܡܡܠܠܐ ܚܐܪܐ',
      'privacy_notice': '100% ܕܠܐ ܢܘܠܐ',
      'settings': 'ܛܘܟܣ̈ܐ',
    },
    'mt': {
      'app_title': 'Polyglot Sovran',
      'start_practice': 'Ibda l-Prattika',
      'review_due': 'Reviżjonijiet Dovuti',
      'dialogue_mode': 'Konverżazzjoni Ħielsa',
      'privacy_notice': '100% Offline u Sovran',
      'settings': 'Settings',
    },
  };

  /// Returns localized string with fallback to German standard.
  static String translate(String key, {String locale = 'de'}) {
    final lang = locale.toLowerCase();
    final bundle = translations[lang] ?? translations['de']!;
    return bundle[key] ?? translations['de']![key] ?? key;
  }

  /// Determines whether the target language uses Right-to-Left (RTL) text layout.
  static bool isRtl(String locale) {
    final lower = locale.toLowerCase();
    return lower == 'ar' || lower == 'syc' || lower == 'fa' || lower == 'ur';
  }
}
