// Sovereign Polyglot Core - Task 4177 (Supply Chain)
class Task4177Engine {
  static const int taskId = 4177;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'nachplanen';
  static const String praeteritum = 'plante nach';
  static const String perfekt = 'hat nachgeplant';
  static const String arabicTranslation = 'تدقيق / متابعة التخطيط (سلاسل الإمداد)';
  static const String ipaTranscription = '[nachˈˈplaːnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4177_nachplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale nachplanen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التخطيط في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
