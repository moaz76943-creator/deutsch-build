// Sovereign Polyglot Core - Task 3225 (Academic Research)
class Task3225Engine {
  static const int taskId = 3225;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ertragen';
  static const String praeteritum = 'ertrug';
  static const String perfekt = 'hat ertragen';
  static const String arabicTranslation = 'إنجاز / تحقيق المسؤولية (البحث الأكاديمي)';
  static const String ipaTranscription = '[erˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3225_ertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ertragen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق المسؤولية في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
