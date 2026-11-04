// Sovereign Polyglot Core - Task 2398 (Software Architecture)
class Task2398Engine {
  static const int taskId = 2398;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vorziehen';
  static const String praeteritum = 'zog vor';
  static const String perfekt = 'hat vorgezogen';
  static const String arabicTranslation = 'تقديم / تحضير الاستنتاج (هندسة البرمجيات)';
  static const String ipaTranscription = '[vorˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2398_vorziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vorziehen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير الاستنتاج في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
