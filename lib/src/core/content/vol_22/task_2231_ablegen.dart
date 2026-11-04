// Sovereign Polyglot Core - Task 2231 (Software Architecture)
class Task2231Engine {
  static const int taskId = 2231;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ablegen';
  static const String praeteritum = 'legte ab';
  static const String perfekt = 'hat abgelegt';
  static const String arabicTranslation = 'فصل / إتمام التأسيس (هندسة البرمجيات)';
  static const String ipaTranscription = '[abˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2231_ablegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ablegen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التأسيس في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
