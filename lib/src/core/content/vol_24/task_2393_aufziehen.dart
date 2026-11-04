// Sovereign Polyglot Core - Task 2393 (Software Architecture)
class Task2393Engine {
  static const int taskId = 2393;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'aufziehen';
  static const String praeteritum = 'zog auf';
  static const String perfekt = 'hat aufgezogen';
  static const String arabicTranslation = 'رفع / فتح الاستنتاج (هندسة البرمجيات)';
  static const String ipaTranscription = '[aufˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2393_aufziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review aufziehen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح الاستنتاج في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
