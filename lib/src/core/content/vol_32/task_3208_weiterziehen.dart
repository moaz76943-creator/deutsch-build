// Sovereign Polyglot Core - Task 3208 (Academic Research)
class Task3208Engine {
  static const int taskId = 3208;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'weiterziehen';
  static const String praeteritum = 'zog weiter';
  static const String perfekt = 'hat weitergezogen';
  static const String arabicTranslation = 'مواصلة / تمرير الاستنتاج (البحث الأكاديمي)';
  static const String ipaTranscription = '[weiterˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3208_weiterziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt weiterziehen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير الاستنتاج في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
