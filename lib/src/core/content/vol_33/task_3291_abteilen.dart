// Sovereign Polyglot Core - Task 3291 (Academic Research)
class Task3291Engine {
  static const int taskId = 3291;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'abteilen';
  static const String praeteritum = 'teilte ab';
  static const String perfekt = 'hat abgeteilt';
  static const String arabicTranslation = 'فصل / إتمام التقسيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3291_abteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt abteilen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التقسيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
