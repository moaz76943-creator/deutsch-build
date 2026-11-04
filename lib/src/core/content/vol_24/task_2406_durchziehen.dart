// Sovereign Polyglot Core - Task 2406 (Software Architecture)
class Task2406Engine {
  static const int taskId = 2406;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'durchziehen';
  static const String praeteritum = 'zog durch';
  static const String perfekt = 'hat durchgezogen';
  static const String arabicTranslation = 'إتمام شامل الاستنتاج (هندسة البرمجيات)';
  static const String ipaTranscription = '[durchˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2406_durchziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review durchziehen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل الاستنتاج في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
