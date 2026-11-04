// Sovereign Polyglot Core - Task 4369 (Supply Chain)
class Task4369Engine {
  static const int taskId = 4369;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'zusammenschreiben';
  static const String praeteritum = 'schrieb zusammen';
  static const String perfekt = 'hat zusammengeschrieben';
  static const String arabicTranslation = 'تجميع / توحيد التدوين (سلاسل الإمداد)';
  static const String ipaTranscription = '[zusammenˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4369_zusammenschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale zusammenschreiben.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التدوين في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
