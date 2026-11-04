// Sovereign Polyglot Core - Task 4367 (Supply Chain)
class Task4367Engine {
  static const int taskId = 4367;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'umschreiben';
  static const String praeteritum = 'schrieb um';
  static const String perfekt = 'hat umgeschrieben';
  static const String arabicTranslation = 'إعادة هيكلة التدوين (سلاسل الإمداد)';
  static const String ipaTranscription = '[umˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4367_umschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale umschreiben.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التدوين في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
