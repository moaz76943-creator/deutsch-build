// Sovereign Polyglot Core - Task 2402 (Software Architecture)
class Task2402Engine {
  static const int taskId = 2402;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'verziehen';
  static const String praeteritum = 'verzog';
  static const String perfekt = 'hat verzogen';
  static const String arabicTranslation = 'توثيق / معالجة الاستنتاج (هندسة البرمجيات)';
  static const String ipaTranscription = '[verˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2402_verziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review verziehen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة الاستنتاج في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
