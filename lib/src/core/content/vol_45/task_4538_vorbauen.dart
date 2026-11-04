// Sovereign Polyglot Core - Task 4538 (Supply Chain)
class Task4538Engine {
  static const int taskId = 4538;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'vorbauen';
  static const String praeteritum = 'baute vor';
  static const String perfekt = 'hat vorgebaut';
  static const String arabicTranslation = 'تقديم / تحضير التطوير (سلاسل الإمداد)';
  static const String ipaTranscription = '[vorˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4538_vorbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale vorbauen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التطوير في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
