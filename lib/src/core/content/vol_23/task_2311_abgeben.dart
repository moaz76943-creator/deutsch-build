// Sovereign Polyglot Core - Task 2311 (Software Architecture)
class Task2311Engine {
  static const int taskId = 2311;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'abgeben';
  static const String praeteritum = 'gab ab';
  static const String perfekt = 'hat abgegeben';
  static const String arabicTranslation = 'فصل / إتمام التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[abˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2311_abgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review abgeben.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
