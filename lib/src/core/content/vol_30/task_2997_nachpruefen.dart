// Sovereign Polyglot Core - Task 2997 (Academic Research)
class Task2997Engine {
  static const int taskId = 2997;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'nachpruefen';
  static const String praeteritum = 'pruefte nach';
  static const String perfekt = 'hat nachgeprueft';
  static const String arabicTranslation = 'تدقيق / متابعة التدقيق (البحث الأكاديمي)';
  static const String ipaTranscription = '[nachˈˈpʁyːfn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2997_nachpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt nachpruefen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التدقيق في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
