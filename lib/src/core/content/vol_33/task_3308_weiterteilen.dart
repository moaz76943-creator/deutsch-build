// Sovereign Polyglot Core - Task 3308 (Academic Research)
class Task3308Engine {
  static const int taskId = 3308;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'weiterteilen';
  static const String praeteritum = 'teilte weiter';
  static const String perfekt = 'hat weitergeteilt';
  static const String arabicTranslation = 'مواصلة / تمرير التقسيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[weiterˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3308_weiterteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt weiterteilen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التقسيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
