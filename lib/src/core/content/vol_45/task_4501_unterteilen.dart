// Sovereign Polyglot Core - Task 4501 (Supply Chain)
class Task4501Engine {
  static const int taskId = 4501;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'unterteilen';
  static const String praeteritum = 'unterteilte';
  static const String perfekt = 'hat unterteilt';
  static const String arabicTranslation = 'فحص / دعم التقسيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[unterˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4501_unterteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale unterteilen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التقسيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
