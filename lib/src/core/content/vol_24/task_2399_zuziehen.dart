// Sovereign Polyglot Core - Task 2399 (Software Architecture)
class Task2399Engine {
  static const int taskId = 2399;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zuziehen';
  static const String praeteritum = 'zog zu';
  static const String perfekt = 'hat zugezogen';
  static const String arabicTranslation = 'توجيه / إغلاق الاستنتاج (هندسة البرمجيات)';
  static const String ipaTranscription = '[zuˈˈtsiːən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2399_zuziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zuziehen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق الاستنتاج في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
