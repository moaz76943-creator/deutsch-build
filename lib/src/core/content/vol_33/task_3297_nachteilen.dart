// Sovereign Polyglot Core - Task 3297 (Academic Research)
class Task3297Engine {
  static const int taskId = 3297;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'nachteilen';
  static const String praeteritum = 'teilte nach';
  static const String perfekt = 'hat nachgeteilt';
  static const String arabicTranslation = 'تدقيق / متابعة التقسيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[nachˈˈtaɪ̯lən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3297_nachteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt nachteilen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التقسيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
