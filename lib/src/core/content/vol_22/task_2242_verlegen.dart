// Sovereign Polyglot Core - Task 2242 (Software Architecture)
class Task2242Engine {
  static const int taskId = 2242;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'verlegen';
  static const String praeteritum = 'verlegte';
  static const String perfekt = 'hat verlegt';
  static const String arabicTranslation = 'توثيق / معالجة التأسيس (هندسة البرمجيات)';
  static const String ipaTranscription = '[verˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2242_verlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review verlegen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التأسيس في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
