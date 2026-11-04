// Sovereign Polyglot Core - Task 4363 (Supply Chain)
class Task4363Engine {
  static const int taskId = 4363;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'entschreiben';
  static const String praeteritum = 'entschrieb';
  static const String perfekt = 'hat entschrieben';
  static const String arabicTranslation = 'استخلاص / كشف التدوين (سلاسل الإمداد)';
  static const String ipaTranscription = '[entˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4363_entschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale entschreiben.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التدوين في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
