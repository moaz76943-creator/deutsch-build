// Sovereign Polyglot Core - Task 4351 (Supply Chain)
class Task4351Engine {
  static const int taskId = 4351;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'abschreiben';
  static const String praeteritum = 'schrieb ab';
  static const String perfekt = 'hat abgeschrieben';
  static const String arabicTranslation = 'فصل / إتمام التدوين (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4351_abschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale abschreiben.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التدوين في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
