// Sovereign Polyglot Core - Task 4418 (Supply Chain)
class Task4418Engine {
  static const int taskId = 4418;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'vortragen';
  static const String praeteritum = 'trug vor';
  static const String perfekt = 'hat vorgetragen';
  static const String arabicTranslation = 'تقديم / تحضير المسؤولية (سلاسل الإمداد)';
  static const String ipaTranscription = '[vorˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4418_vortragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale vortragen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير المسؤولية في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
