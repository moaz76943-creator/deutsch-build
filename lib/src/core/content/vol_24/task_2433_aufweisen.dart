// Sovereign Polyglot Core - Task 2433 (Software Architecture)
class Task2433Engine {
  static const int taskId = 2433;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'aufweisen';
  static const String praeteritum = 'wies auf';
  static const String perfekt = 'hat aufgewiesen';
  static const String arabicTranslation = 'رفع / فتح التوجيه (هندسة البرمجيات)';
  static const String ipaTranscription = '[aufˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2433_aufweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review aufweisen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التوجيه في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
