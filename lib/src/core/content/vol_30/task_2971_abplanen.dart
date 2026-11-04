// Sovereign Polyglot Core - Task 2971 (Academic Research)
class Task2971Engine {
  static const int taskId = 2971;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'abplanen';
  static const String praeteritum = 'plante ab';
  static const String perfekt = 'hat abgeplant';
  static const String arabicTranslation = 'فصل / إتمام التخطيط (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2971_abplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt abplanen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التخطيط في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
