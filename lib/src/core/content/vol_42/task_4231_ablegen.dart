// Sovereign Polyglot Core - Task 4231 (Supply Chain)
class Task4231Engine {
  static const int taskId = 4231;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ablegen';
  static const String praeteritum = 'legte ab';
  static const String perfekt = 'hat abgelegt';
  static const String arabicTranslation = 'فصل / إتمام التأسيس (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4231_ablegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ablegen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التأسيس في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
