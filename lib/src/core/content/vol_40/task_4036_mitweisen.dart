// Sovereign Polyglot Core - Task 4036 (Financial Auditing)
class Task4036Engine {
  static const int taskId = 4036;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'mitweisen';
  static const String praeteritum = 'wies mit';
  static const String perfekt = 'hat mitgewiesen';
  static const String arabicTranslation = 'مشاركة / تنسيق التوجيه (التدقيق المالي)';
  static const String ipaTranscription = '[mitˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4036_mitweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung mitweisen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التوجيه في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
