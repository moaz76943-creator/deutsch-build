// Sovereign Polyglot Core - Task 3331 (Academic Research)
class Task3331Engine {
  static const int taskId = 3331;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'abbauen';
  static const String praeteritum = 'baute ab';
  static const String perfekt = 'hat abgebaut';
  static const String arabicTranslation = 'فصل / إتمام التطوير (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3331_abbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt abbauen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التطوير في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
