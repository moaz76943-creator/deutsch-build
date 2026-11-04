// Sovereign Polyglot Core - Task 3304 (Academic Research)
class Task3304Engine {
  static const int taskId = 3304;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'beteilen';
  static const String praeteritum = 'beteilte';
  static const String perfekt = 'hat beteilt';
  static const String arabicTranslation = 'تأكيد / تزويد التقسيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[beˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3304_beteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt beteilen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التقسيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
