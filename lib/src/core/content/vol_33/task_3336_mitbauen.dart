// Sovereign Polyglot Core - Task 3336 (Academic Research)
class Task3336Engine {
  static const int taskId = 3336;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'mitbauen';
  static const String praeteritum = 'baute mit';
  static const String perfekt = 'hat mitgebaut';
  static const String arabicTranslation = 'مشاركة / تنسيق التطوير (البحث الأكاديمي)';
  static const String ipaTranscription = '[mitˈˈbaʊ̯ən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3336_mitbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt mitbauen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التطوير في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
