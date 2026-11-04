// Sovereign Polyglot Core - Task 4497 (Supply Chain)
class Task4497Engine {
  static const int taskId = 4497;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'nachteilen';
  static const String praeteritum = 'teilte nach';
  static const String perfekt = 'hat nachgeteilt';
  static const String arabicTranslation = 'تدقيق / متابعة التقسيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[nachˈˈtaɪ̯lən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4497_nachteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale nachteilen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التقسيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
