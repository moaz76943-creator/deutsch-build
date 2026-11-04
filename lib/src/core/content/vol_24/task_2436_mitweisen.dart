// Sovereign Polyglot Core - Task 2436 (Software Architecture)
class Task2436Engine {
  static const int taskId = 2436;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'mitweisen';
  static const String praeteritum = 'wies mit';
  static const String perfekt = 'hat mitgewiesen';
  static const String arabicTranslation = 'مشاركة / تنسيق التوجيه (هندسة البرمجيات)';
  static const String ipaTranscription = '[mitˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2436_mitweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review mitweisen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التوجيه في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
