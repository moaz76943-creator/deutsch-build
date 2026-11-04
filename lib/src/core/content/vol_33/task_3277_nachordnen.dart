// Sovereign Polyglot Core - Task 3277 (Academic Research)
class Task3277Engine {
  static const int taskId = 3277;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'nachordnen';
  static const String praeteritum = 'ordnete nach';
  static const String perfekt = 'hat nachgeordnet';
  static const String arabicTranslation = 'تدقيق / متابعة التصنيف (البحث الأكاديمي)';
  static const String ipaTranscription = '[nachˈˈɔʁdnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3277_nachordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt nachordnen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التصنيف في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
