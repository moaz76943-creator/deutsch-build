// Sovereign Polyglot Core - Task 3133 (Academic Research)
class Task3133Engine {
  static const int taskId = 3133;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'aufhalten';
  static const String praeteritum = 'hielt auf';
  static const String perfekt = 'hat aufgehalten';
  static const String arabicTranslation = 'رفع / فتح الالتزام (البحث الأكاديمي)';
  static const String ipaTranscription = '[aufˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3133_aufhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt aufhalten.';
  static const String exampleArabic = 'يجب علينا رفع / فتح الالتزام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
