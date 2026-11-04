// Sovereign Polyglot Core - Task 3036 (Academic Research)
class Task3036Engine {
  static const int taskId = 3036;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'mitlegen';
  static const String praeteritum = 'legte mit';
  static const String perfekt = 'hat mitgelegt';
  static const String arabicTranslation = 'مشاركة / تنسيق التأسيس (البحث الأكاديمي)';
  static const String ipaTranscription = '[mitˈˈleːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3036_mitlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt mitlegen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التأسيس في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
