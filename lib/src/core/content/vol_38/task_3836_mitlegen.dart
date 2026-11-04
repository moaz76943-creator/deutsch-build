// Sovereign Polyglot Core - Task 3836 (Financial Auditing)
class Task3836Engine {
  static const int taskId = 3836;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'mitlegen';
  static const String praeteritum = 'legte mit';
  static const String perfekt = 'hat mitgelegt';
  static const String arabicTranslation = 'مشاركة / تنسيق التأسيس (التدقيق المالي)';
  static const String ipaTranscription = '[mitˈˈleːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3836_mitlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung mitlegen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التأسيس في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
