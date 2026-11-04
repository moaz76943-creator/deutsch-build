// Sovereign Polyglot Core - Task 3096 (Academic Research)
class Task3096Engine {
  static const int taskId = 3096;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'mitnehmen';
  static const String praeteritum = 'nahm mit';
  static const String perfekt = 'hat mitgenommen';
  static const String arabicTranslation = 'مشاركة / تنسيق الاستلام (البحث الأكاديمي)';
  static const String ipaTranscription = '[mitˈˈneːmən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3096_mitnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt mitnehmen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق الاستلام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
