// Sovereign Polyglot Core - Task 4536 (Supply Chain)
class Task4536Engine {
  static const int taskId = 4536;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'mitbauen';
  static const String praeteritum = 'baute mit';
  static const String perfekt = 'hat mitgebaut';
  static const String arabicTranslation = 'مشاركة / تنسيق التطوير (سلاسل الإمداد)';
  static const String ipaTranscription = '[mitˈˈbaʊ̯ən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4536_mitbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale mitbauen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التطوير في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
