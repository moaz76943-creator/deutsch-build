// Sovereign Polyglot Core - Task 2404 (Software Architecture)
class Task2404Engine {
  static const int taskId = 2404;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'beziehen';
  static const String praeteritum = 'bezog';
  static const String perfekt = 'hat bezogen';
  static const String arabicTranslation = 'تأكيد / تزويد الاستنتاج (هندسة البرمجيات)';
  static const String ipaTranscription = '[beˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2404_beziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review beziehen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد الاستنتاج في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
