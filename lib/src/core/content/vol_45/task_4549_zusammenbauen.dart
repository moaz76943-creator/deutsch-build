// Sovereign Polyglot Core - Task 4549 (Supply Chain)
class Task4549Engine {
  static const int taskId = 4549;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'zusammenbauen';
  static const String praeteritum = 'baute zusammen';
  static const String perfekt = 'hat zusammengebaut';
  static const String arabicTranslation = 'تجميع / توحيد التطوير (سلاسل الإمداد)';
  static const String ipaTranscription = '[zusammenˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4549_zusammenbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale zusammenbauen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التطوير في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
