// Sovereign Polyglot Core - Task 4502 (Supply Chain)
class Task4502Engine {
  static const int taskId = 4502;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'verteilen';
  static const String praeteritum = 'verteilte';
  static const String perfekt = 'hat verteilt';
  static const String arabicTranslation = 'توثيق / معالجة التقسيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[verˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4502_verteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale verteilen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التقسيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
