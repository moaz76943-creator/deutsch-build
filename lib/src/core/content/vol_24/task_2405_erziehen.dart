// Sovereign Polyglot Core - Task 2405 (Software Architecture)
class Task2405Engine {
  static const int taskId = 2405;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'erziehen';
  static const String praeteritum = 'erzog';
  static const String perfekt = 'hat erzogen';
  static const String arabicTranslation = 'إنجاز / تحقيق الاستنتاج (هندسة البرمجيات)';
  static const String ipaTranscription = '[erˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2405_erziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review erziehen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق الاستنتاج في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
