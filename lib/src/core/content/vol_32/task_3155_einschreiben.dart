// Sovereign Polyglot Core - Task 3155 (Academic Research)
class Task3155Engine {
  static const int taskId = 3155;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'einschreiben';
  static const String praeteritum = 'schrieb ein';
  static const String perfekt = 'hat eingeschrieben';
  static const String arabicTranslation = 'إدراج / دمج التدوين (البحث الأكاديمي)';
  static const String ipaTranscription = '[einˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3155_einschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt einschreiben.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التدوين في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
