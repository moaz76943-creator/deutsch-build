// Sovereign Polyglot Core - Task 3956 (Financial Auditing)
class Task3956Engine {
  static const int taskId = 3956;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'mitschreiben';
  static const String praeteritum = 'schrieb mit';
  static const String perfekt = 'hat mitgeschrieben';
  static const String arabicTranslation = 'مشاركة / تنسيق التدوين (التدقيق المالي)';
  static const String ipaTranscription = '[mitˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3956_mitschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung mitschreiben.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التدوين في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
