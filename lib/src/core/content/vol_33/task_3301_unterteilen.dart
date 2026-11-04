// Sovereign Polyglot Core - Task 3301 (Academic Research)
class Task3301Engine {
  static const int taskId = 3301;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'unterteilen';
  static const String praeteritum = 'unterteilte';
  static const String perfekt = 'hat unterteilt';
  static const String arabicTranslation = 'فحص / دعم التقسيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[unterˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3301_unterteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt unterteilen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التقسيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
