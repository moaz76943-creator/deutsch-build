// Sovereign Polyglot Core - Task 2876
class Task2876Engine {
  static const int taskId = 2876;
  static const String verbInfinitive = 'ueberwinden';
  static const String praeteritum = 'ueberwand';
  static const String perfekt = 'hat ueberwunden';
  static const String arabicTranslation = 'يتغلب على عقبة';
  static const String ipaTranscription = '[yːbɐˈvɪndn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String exampleGerman = 'Sie ueberwand alle Huerden.';
  static const String exampleArabic = 'تغلبت على جميع العقبات.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'verb': verbInfinitive, 'praeteritum': praeteritum,
    'perfekt': perfekt, 'arabic': arabicTranslation, 'ipa': ipaTranscription,
    'case': valencyCase, 'cefr': cefrLevel, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && praeteritum.isNotEmpty && perfekt.isNotEmpty;
}
