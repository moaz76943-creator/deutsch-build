// Sovereign Polyglot Core - Task 3238 (Academic Research)
class Task3238Engine {
  static const int taskId = 3238;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'vorweisen';
  static const String praeteritum = 'wies vor';
  static const String perfekt = 'hat vorgewiesen';
  static const String arabicTranslation = 'تقديم / تحضير التوجيه (البحث الأكاديمي)';
  static const String ipaTranscription = '[vorˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3238_vorweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt vorweisen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التوجيه في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
