// Sovereign Polyglot Core - Task 4300 (Supply Chain)
class Task4300Engine {
  static const int taskId = 4300;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'uebernehmen';
  static const String praeteritum = 'uebernahm';
  static const String perfekt = 'hat uebernommen';
  static const String arabicTranslation = 'مراجعة / نقل الاستلام (سلاسل الإمداد)';
  static const String ipaTranscription = '[ueberˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4300_uebernehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale uebernehmen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الاستلام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
