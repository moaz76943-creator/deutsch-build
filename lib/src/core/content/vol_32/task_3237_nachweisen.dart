// Sovereign Polyglot Core - Task 3237 (Academic Research)
class Task3237Engine {
  static const int taskId = 3237;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'nachweisen';
  static const String praeteritum = 'wies nach';
  static const String perfekt = 'hat nachgewiesen';
  static const String arabicTranslation = 'تدقيق / متابعة التوجيه (البحث الأكاديمي)';
  static const String ipaTranscription = '[nachˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3237_nachweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt nachweisen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التوجيه في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
