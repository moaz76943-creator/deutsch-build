// Sovereign Polyglot Core - Task 3245 (Academic Research)
class Task3245Engine {
  static const int taskId = 3245;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'erweisen';
  static const String praeteritum = 'erwies';
  static const String perfekt = 'hat erwiesen';
  static const String arabicTranslation = 'إنجاز / تحقيق التوجيه (البحث الأكاديمي)';
  static const String ipaTranscription = '[erˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3245_erweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt erweisen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التوجيه في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
