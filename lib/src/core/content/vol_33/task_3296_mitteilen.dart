// Sovereign Polyglot Core - Task 3296 (Academic Research)
class Task3296Engine {
  static const int taskId = 3296;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'mitteilen';
  static const String praeteritum = 'teilte mit';
  static const String perfekt = 'hat mitgeteilt';
  static const String arabicTranslation = 'مشاركة / تنسيق التقسيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[mitˈˈtaɪ̯lən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3296_mitteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt mitteilen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التقسيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
