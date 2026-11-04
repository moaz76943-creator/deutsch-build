// Sovereign Polyglot Core - Task 2397 (Software Architecture)
class Task2397Engine {
  static const int taskId = 2397;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'nachziehen';
  static const String praeteritum = 'zog nach';
  static const String perfekt = 'hat nachgezogen';
  static const String arabicTranslation = 'تدقيق / متابعة الاستنتاج (هندسة البرمجيات)';
  static const String ipaTranscription = '[nachˈˈtsiːən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2397_nachziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review nachziehen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة الاستنتاج في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
