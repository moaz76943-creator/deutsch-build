// Sovereign Polyglot Core - Task 3329 (Academic Research)
class Task3329Engine {
  static const int taskId = 3329;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'zusammenschliessen';
  static const String praeteritum = 'schloss zusammen';
  static const String perfekt = 'hat zusammengeschlossen';
  static const String arabicTranslation = 'تجميع / توحيد الإبرام (البحث الأكاديمي)';
  static const String ipaTranscription = '[zusammenˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3329_zusammenschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt zusammenschliessen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد الإبرام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
