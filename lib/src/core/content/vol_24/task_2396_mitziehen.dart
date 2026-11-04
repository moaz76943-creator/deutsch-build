// Sovereign Polyglot Core - Task 2396 (Software Architecture)
class Task2396Engine {
  static const int taskId = 2396;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'mitziehen';
  static const String praeteritum = 'zog mit';
  static const String perfekt = 'hat mitgezogen';
  static const String arabicTranslation = 'مشاركة / تنسيق الاستنتاج (هندسة البرمجيات)';
  static const String ipaTranscription = '[mitˈˈtsiːən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2396_mitziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review mitziehen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق الاستنتاج في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
