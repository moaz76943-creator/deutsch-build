// Sovereign Polyglot Core - Task 3976 (Financial Auditing)
class Task3976Engine {
  static const int taskId = 3976;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'mitsprechen';
  static const String praeteritum = 'sprach mit';
  static const String perfekt = 'hat mitgesprochen';
  static const String arabicTranslation = 'مشاركة / تنسيق التخاطب (التدقيق المالي)';
  static const String ipaTranscription = '[mitˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3976_mitsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung mitsprechen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التخاطب في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
