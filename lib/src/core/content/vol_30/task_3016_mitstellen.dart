// Sovereign Polyglot Core - Task 3016 (Academic Research)
class Task3016Engine {
  static const int taskId = 3016;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'mitstellen';
  static const String praeteritum = 'stellte mit';
  static const String perfekt = 'hat mitgestellt';
  static const String arabicTranslation = 'مشاركة / تنسيق التنظيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[mitˈˈʃtɛlən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3016_mitstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt mitstellen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التنظيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
