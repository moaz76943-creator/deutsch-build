// Sovereign Polyglot Core - Task 3198 (Academic Research)
class Task3198Engine {
  static const int taskId = 3198;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'vorziehen';
  static const String praeteritum = 'zog vor';
  static const String perfekt = 'hat vorgezogen';
  static const String arabicTranslation = 'تقديم / تحضير الاستنتاج (البحث الأكاديمي)';
  static const String ipaTranscription = '[vorˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3198_vorziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt vorziehen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير الاستنتاج في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
