// Sovereign Polyglot Core - Task 4398 (Supply Chain)
class Task4398Engine {
  static const int taskId = 4398;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'vorziehen';
  static const String praeteritum = 'zog vor';
  static const String perfekt = 'hat vorgezogen';
  static const String arabicTranslation = 'تقديم / تحضير الاستنتاج (سلاسل الإمداد)';
  static const String ipaTranscription = '[vorˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4398_vorziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale vorziehen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير الاستنتاج في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
