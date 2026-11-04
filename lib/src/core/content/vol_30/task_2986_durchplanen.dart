// Sovereign Polyglot Core - Task 2986 (Academic Research)
class Task2986Engine {
  static const int taskId = 2986;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'durchplanen';
  static const String praeteritum = 'plante durch';
  static const String perfekt = 'hat durchgeplant';
  static const String arabicTranslation = 'إتمام شامل التخطيط (البحث الأكاديمي)';
  static const String ipaTranscription = '[durchˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2986_durchplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt durchplanen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التخطيط في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
