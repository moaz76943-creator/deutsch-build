// Sovereign Polyglot Core - Task 4438 (Supply Chain)
class Task4438Engine {
  static const int taskId = 4438;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'vorweisen';
  static const String praeteritum = 'wies vor';
  static const String perfekt = 'hat vorgewiesen';
  static const String arabicTranslation = 'تقديم / تحضير التوجيه (سلاسل الإمداد)';
  static const String ipaTranscription = '[vorˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4438_vorweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale vorweisen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التوجيه في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
