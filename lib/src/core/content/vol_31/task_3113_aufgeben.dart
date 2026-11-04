// Sovereign Polyglot Core - Task 3113 (Academic Research)
class Task3113Engine {
  static const int taskId = 3113;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'aufgeben';
  static const String praeteritum = 'gab auf';
  static const String perfekt = 'hat aufgegeben';
  static const String arabicTranslation = 'رفع / فتح التسليم (البحث الأكاديمي)';
  static const String ipaTranscription = '[aufˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3113_aufgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt aufgeben.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التسليم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
