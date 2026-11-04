// Sovereign Polyglot Core - Task 4356 (Supply Chain)
class Task4356Engine {
  static const int taskId = 4356;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'mitschreiben';
  static const String praeteritum = 'schrieb mit';
  static const String perfekt = 'hat mitgeschrieben';
  static const String arabicTranslation = 'مشاركة / تنسيق التدوين (سلاسل الإمداد)';
  static const String ipaTranscription = '[mitˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4356_mitschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale mitschreiben.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التدوين في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
