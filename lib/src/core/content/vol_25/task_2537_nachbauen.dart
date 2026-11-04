// Sovereign Polyglot Core - Task 2537 (Software Architecture)
class Task2537Engine {
  static const int taskId = 2537;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'nachbauen';
  static const String praeteritum = 'baute nach';
  static const String perfekt = 'hat nachgebaut';
  static const String arabicTranslation = 'تدقيق / متابعة التطوير (هندسة البرمجيات)';
  static const String ipaTranscription = '[nachˈˈbaʊ̯ən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2537_nachbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review nachbauen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التطوير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
