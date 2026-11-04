// Sovereign Polyglot Core - Task 2978 (Academic Research)
class Task2978Engine {
  static const int taskId = 2978;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'vorplanen';
  static const String praeteritum = 'plante vor';
  static const String perfekt = 'hat vorgeplant';
  static const String arabicTranslation = 'تقديم / تحضير التخطيط (البحث الأكاديمي)';
  static const String ipaTranscription = '[vorˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2978_vorplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt vorplanen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التخطيط في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
