// Sovereign Polyglot Core - Task 3236 (Academic Research)
class Task3236Engine {
  static const int taskId = 3236;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'mitweisen';
  static const String praeteritum = 'wies mit';
  static const String perfekt = 'hat mitgewiesen';
  static const String arabicTranslation = 'مشاركة / تنسيق التوجيه (البحث الأكاديمي)';
  static const String ipaTranscription = '[mitˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3236_mitweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt mitweisen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التوجيه في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
