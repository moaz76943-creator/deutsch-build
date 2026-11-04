// Sovereign Polyglot Core - Task 4237 (Supply Chain)
class Task4237Engine {
  static const int taskId = 4237;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'nachlegen';
  static const String praeteritum = 'legte nach';
  static const String perfekt = 'hat nachgelegt';
  static const String arabicTranslation = 'تدقيق / متابعة التأسيس (سلاسل الإمداد)';
  static const String ipaTranscription = '[nachˈˈleːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4237_nachlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale nachlegen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التأسيس في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
