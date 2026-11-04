// Sovereign Polyglot Core - Task 3349 (Academic Research)
class Task3349Engine {
  static const int taskId = 3349;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'zusammenbauen';
  static const String praeteritum = 'baute zusammen';
  static const String perfekt = 'hat zusammengebaut';
  static const String arabicTranslation = 'تجميع / توحيد التطوير (البحث الأكاديمي)';
  static const String ipaTranscription = '[zusammenˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3349_zusammenbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt zusammenbauen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التطوير في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
