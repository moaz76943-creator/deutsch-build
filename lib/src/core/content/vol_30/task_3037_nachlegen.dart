// Sovereign Polyglot Core - Task 3037 (Academic Research)
class Task3037Engine {
  static const int taskId = 3037;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'nachlegen';
  static const String praeteritum = 'legte nach';
  static const String perfekt = 'hat nachgelegt';
  static const String arabicTranslation = 'تدقيق / متابعة التأسيس (البحث الأكاديمي)';
  static const String ipaTranscription = '[nachˈˈleːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3037_nachlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt nachlegen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التأسيس في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
