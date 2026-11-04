// Sovereign Polyglot Core - Task 3309 (Academic Research)
class Task3309Engine {
  static const int taskId = 3309;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'zusammenteilen';
  static const String praeteritum = 'teilte zusammen';
  static const String perfekt = 'hat zusammengeteilt';
  static const String arabicTranslation = 'تجميع / توحيد التقسيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[zusammenˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3309_zusammenteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt zusammenteilen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التقسيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
