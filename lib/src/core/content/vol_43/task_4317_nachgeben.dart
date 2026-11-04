// Sovereign Polyglot Core - Task 4317 (Supply Chain)
class Task4317Engine {
  static const int taskId = 4317;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'nachgeben';
  static const String praeteritum = 'gab nach';
  static const String perfekt = 'hat nachgegeben';
  static const String arabicTranslation = 'تدقيق / متابعة التسليم (سلاسل الإمداد)';
  static const String ipaTranscription = '[nachˈˈɡeːbn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4317_nachgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale nachgeben.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التسليم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
