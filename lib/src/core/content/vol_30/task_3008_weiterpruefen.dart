// Sovereign Polyglot Core - Task 3008 (Academic Research)
class Task3008Engine {
  static const int taskId = 3008;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'weiterpruefen';
  static const String praeteritum = 'pruefte weiter';
  static const String perfekt = 'hat weitergeprueft';
  static const String arabicTranslation = 'مواصلة / تمرير التدقيق (البحث الأكاديمي)';
  static const String ipaTranscription = '[weiterˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3008_weiterpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt weiterpruefen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التدقيق في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
