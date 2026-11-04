// Sovereign Polyglot Core - Task 3345 (Academic Research)
class Task3345Engine {
  static const int taskId = 3345;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'erbauen';
  static const String praeteritum = 'erbaute';
  static const String perfekt = 'hat erbaut';
  static const String arabicTranslation = 'إنجاز / تحقيق التطوير (البحث الأكاديمي)';
  static const String ipaTranscription = '[erˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3345_erbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt erbauen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التطوير في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
