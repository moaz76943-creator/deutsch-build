// Sovereign Polyglot Core - Task 3158 (Academic Research)
class Task3158Engine {
  static const int taskId = 3158;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'vorschreiben';
  static const String praeteritum = 'schrieb vor';
  static const String perfekt = 'hat vorgeschrieben';
  static const String arabicTranslation = 'تقديم / تحضير التدوين (البحث الأكاديمي)';
  static const String ipaTranscription = '[vorˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3158_vorschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt vorschreiben.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التدوين في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
