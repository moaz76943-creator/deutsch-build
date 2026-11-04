// Sovereign Polyglot Core - Task 2437 (Software Architecture)
class Task2437Engine {
  static const int taskId = 2437;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'nachweisen';
  static const String praeteritum = 'wies nach';
  static const String perfekt = 'hat nachgewiesen';
  static const String arabicTranslation = 'تدقيق / متابعة التوجيه (هندسة البرمجيات)';
  static const String ipaTranscription = '[nachˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2437_nachweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review nachweisen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التوجيه في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
