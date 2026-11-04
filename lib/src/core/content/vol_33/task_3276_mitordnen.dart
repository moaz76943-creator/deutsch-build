// Sovereign Polyglot Core - Task 3276 (Academic Research)
class Task3276Engine {
  static const int taskId = 3276;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'mitordnen';
  static const String praeteritum = 'ordnete mit';
  static const String perfekt = 'hat mitgeordnet';
  static const String arabicTranslation = 'مشاركة / تنسيق التصنيف (البحث الأكاديمي)';
  static const String ipaTranscription = '[mitˈˈɔʁdnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3276_mitordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt mitordnen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التصنيف في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
