// Sovereign Polyglot Core - Task 2977 (Academic Research)
class Task2977Engine {
  static const int taskId = 2977;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'nachplanen';
  static const String praeteritum = 'plante nach';
  static const String perfekt = 'hat nachgeplant';
  static const String arabicTranslation = 'تدقيق / متابعة التخطيط (البحث الأكاديمي)';
  static const String ipaTranscription = '[nachˈˈplaːnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2977_nachplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt nachplanen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التخطيط في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
