// Sovereign Polyglot Core - Task 4360 (Supply Chain)
class Task4360Engine {
  static const int taskId = 4360;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ueberschreiben';
  static const String praeteritum = 'ueberschrieb';
  static const String perfekt = 'hat ueberschrieben';
  static const String arabicTranslation = 'مراجعة / نقل التدوين (سلاسل الإمداد)';
  static const String ipaTranscription = '[ueberˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4360_ueberschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ueberschreiben.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التدوين في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
