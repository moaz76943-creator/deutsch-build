// Sovereign Polyglot Core - Task 3176 (Academic Research)
class Task3176Engine {
  static const int taskId = 3176;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'mitsprechen';
  static const String praeteritum = 'sprach mit';
  static const String perfekt = 'hat mitgesprochen';
  static const String arabicTranslation = 'مشاركة / تنسيق التخاطب (البحث الأكاديمي)';
  static const String ipaTranscription = '[mitˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3176_mitsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt mitsprechen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التخاطب في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
