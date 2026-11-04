// Sovereign Polyglot Core - Task 4504 (Supply Chain)
class Task4504Engine {
  static const int taskId = 4504;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'beteilen';
  static const String praeteritum = 'beteilte';
  static const String perfekt = 'hat beteilt';
  static const String arabicTranslation = 'تأكيد / تزويد التقسيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[beˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4504_beteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale beteilen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التقسيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
