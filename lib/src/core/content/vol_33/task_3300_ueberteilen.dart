// Sovereign Polyglot Core - Task 3300 (Academic Research)
class Task3300Engine {
  static const int taskId = 3300;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ueberteilen';
  static const String praeteritum = 'ueberteilte';
  static const String perfekt = 'hat ueberteilt';
  static const String arabicTranslation = 'مراجعة / نقل التقسيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[ueberˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3300_ueberteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ueberteilen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التقسيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
