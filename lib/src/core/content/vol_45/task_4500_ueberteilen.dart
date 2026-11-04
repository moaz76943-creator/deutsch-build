// Sovereign Polyglot Core - Task 4500 (Supply Chain)
class Task4500Engine {
  static const int taskId = 4500;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ueberteilen';
  static const String praeteritum = 'ueberteilte';
  static const String perfekt = 'hat ueberteilt';
  static const String arabicTranslation = 'مراجعة / نقل التقسيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[ueberˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4500_ueberteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ueberteilen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التقسيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
