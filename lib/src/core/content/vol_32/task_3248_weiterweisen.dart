// Sovereign Polyglot Core - Task 3248 (Academic Research)
class Task3248Engine {
  static const int taskId = 3248;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'weiterweisen';
  static const String praeteritum = 'wies weiter';
  static const String perfekt = 'hat weitergewiesen';
  static const String arabicTranslation = 'مواصلة / تمرير التوجيه (البحث الأكاديمي)';
  static const String ipaTranscription = '[weiterˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3248_weiterweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt weiterweisen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التوجيه في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
