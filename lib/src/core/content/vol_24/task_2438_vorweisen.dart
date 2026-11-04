// Sovereign Polyglot Core - Task 2438 (Software Architecture)
class Task2438Engine {
  static const int taskId = 2438;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vorweisen';
  static const String praeteritum = 'wies vor';
  static const String perfekt = 'hat vorgewiesen';
  static const String arabicTranslation = 'تقديم / تحضير التوجيه (هندسة البرمجيات)';
  static const String ipaTranscription = '[vorˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2438_vorweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vorweisen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التوجيه في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
