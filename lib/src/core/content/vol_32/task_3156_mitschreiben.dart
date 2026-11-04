// Sovereign Polyglot Core - Task 3156 (Academic Research)
class Task3156Engine {
  static const int taskId = 3156;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'mitschreiben';
  static const String praeteritum = 'schrieb mit';
  static const String perfekt = 'hat mitgeschrieben';
  static const String arabicTranslation = 'مشاركة / تنسيق التدوين (البحث الأكاديمي)';
  static const String ipaTranscription = '[mitˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3156_mitschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt mitschreiben.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التدوين في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
