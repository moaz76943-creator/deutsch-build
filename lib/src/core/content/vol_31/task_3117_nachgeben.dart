// Sovereign Polyglot Core - Task 3117 (Academic Research)
class Task3117Engine {
  static const int taskId = 3117;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'nachgeben';
  static const String praeteritum = 'gab nach';
  static const String perfekt = 'hat nachgegeben';
  static const String arabicTranslation = 'تدقيق / متابعة التسليم (البحث الأكاديمي)';
  static const String ipaTranscription = '[nachˈˈɡeːbn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3117_nachgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt nachgeben.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التسليم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
