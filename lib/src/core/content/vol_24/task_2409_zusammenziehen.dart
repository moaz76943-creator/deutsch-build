// Sovereign Polyglot Core - Task 2409 (Software Architecture)
class Task2409Engine {
  static const int taskId = 2409;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zusammenziehen';
  static const String praeteritum = 'zog zusammen';
  static const String perfekt = 'hat zusammengezogen';
  static const String arabicTranslation = 'تجميع / توحيد الاستنتاج (هندسة البرمجيات)';
  static const String ipaTranscription = '[zusammenˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2409_zusammenziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zusammenziehen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد الاستنتاج في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
