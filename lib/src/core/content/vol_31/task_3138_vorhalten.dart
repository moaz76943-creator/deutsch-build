// Sovereign Polyglot Core - Task 3138 (Academic Research)
class Task3138Engine {
  static const int taskId = 3138;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'vorhalten';
  static const String praeteritum = 'hielt vor';
  static const String perfekt = 'hat vorgehalten';
  static const String arabicTranslation = 'تقديم / تحضير الالتزام (البحث الأكاديمي)';
  static const String ipaTranscription = '[vorˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3138_vorhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt vorhalten.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير الالتزام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
