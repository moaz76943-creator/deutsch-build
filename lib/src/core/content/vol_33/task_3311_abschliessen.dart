// Sovereign Polyglot Core - Task 3311 (Academic Research)
class Task3311Engine {
  static const int taskId = 3311;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'abschliessen';
  static const String praeteritum = 'schloss ab';
  static const String perfekt = 'hat abgeschlossen';
  static const String arabicTranslation = 'فصل / إتمام الإبرام (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3311_abschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt abschliessen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الإبرام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
