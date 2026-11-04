// Sovereign Polyglot Core - Task 4531 (Supply Chain)
class Task4531Engine {
  static const int taskId = 4531;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'abbauen';
  static const String praeteritum = 'baute ab';
  static const String perfekt = 'hat abgebaut';
  static const String arabicTranslation = 'فصل / إتمام التطوير (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4531_abbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale abbauen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التطوير في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
