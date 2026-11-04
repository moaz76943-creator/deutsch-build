// Sovereign Polyglot Core - Task 2491 (Software Architecture)
class Task2491Engine {
  static const int taskId = 2491;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'abteilen';
  static const String praeteritum = 'teilte ab';
  static const String perfekt = 'hat abgeteilt';
  static const String arabicTranslation = 'فصل / إتمام التقسيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[abˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2491_abteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review abteilen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التقسيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
