// Sovereign Polyglot Core - Task 2395 (Software Architecture)
class Task2395Engine {
  static const int taskId = 2395;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'einziehen';
  static const String praeteritum = 'zog ein';
  static const String perfekt = 'hat eingezogen';
  static const String arabicTranslation = 'إدراج / دمج الاستنتاج (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2395_einziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review einziehen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الاستنتاج في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
