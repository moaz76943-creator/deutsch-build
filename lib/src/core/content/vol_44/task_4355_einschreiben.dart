// Sovereign Polyglot Core - Task 4355 (Supply Chain)
class Task4355Engine {
  static const int taskId = 4355;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'einschreiben';
  static const String praeteritum = 'schrieb ein';
  static const String perfekt = 'hat eingeschrieben';
  static const String arabicTranslation = 'إدراج / دمج التدوين (سلاسل الإمداد)';
  static const String ipaTranscription = '[einˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4355_einschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale einschreiben.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التدوين في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
