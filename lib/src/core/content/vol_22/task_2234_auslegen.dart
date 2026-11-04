// Sovereign Polyglot Core - Task 2234 (Software Architecture)
class Task2234Engine {
  static const int taskId = 2234;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'auslegen';
  static const String praeteritum = 'legte aus';
  static const String perfekt = 'hat ausgelegt';
  static const String arabicTranslation = 'توسيع / استخراج التأسيس (هندسة البرمجيات)';
  static const String ipaTranscription = '[ausˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2234_auslegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review auslegen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التأسيس في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
