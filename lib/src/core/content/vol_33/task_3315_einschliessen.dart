// Sovereign Polyglot Core - Task 3315 (Academic Research)
class Task3315Engine {
  static const int taskId = 3315;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'einschliessen';
  static const String praeteritum = 'schloss ein';
  static const String perfekt = 'hat eingeschlossen';
  static const String arabicTranslation = 'إدراج / دمج الإبرام (البحث الأكاديمي)';
  static const String ipaTranscription = '[einˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3315_einschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt einschliessen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الإبرام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
