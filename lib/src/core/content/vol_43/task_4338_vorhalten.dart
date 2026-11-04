// Sovereign Polyglot Core - Task 4338 (Supply Chain)
class Task4338Engine {
  static const int taskId = 4338;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'vorhalten';
  static const String praeteritum = 'hielt vor';
  static const String perfekt = 'hat vorgehalten';
  static const String arabicTranslation = 'تقديم / تحضير الالتزام (سلاسل الإمداد)';
  static const String ipaTranscription = '[vorˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4338_vorhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale vorhalten.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير الالتزام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
