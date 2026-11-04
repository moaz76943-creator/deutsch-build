// Sovereign Polyglot Core - Task 3125 (Academic Research)
class Task3125Engine {
  static const int taskId = 3125;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ergeben';
  static const String praeteritum = 'ergab';
  static const String perfekt = 'hat ergeben';
  static const String arabicTranslation = 'إنجاز / تحقيق التسليم (البحث الأكاديمي)';
  static const String ipaTranscription = '[erˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3125_ergeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ergeben.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التسليم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
