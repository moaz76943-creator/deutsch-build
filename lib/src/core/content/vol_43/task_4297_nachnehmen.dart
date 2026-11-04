// Sovereign Polyglot Core - Task 4297 (Supply Chain)
class Task4297Engine {
  static const int taskId = 4297;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'nachnehmen';
  static const String praeteritum = 'nahm nach';
  static const String perfekt = 'hat nachgenommen';
  static const String arabicTranslation = 'تدقيق / متابعة الاستلام (سلاسل الإمداد)';
  static const String ipaTranscription = '[nachˈˈneːmən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4297_nachnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale nachnehmen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة الاستلام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
