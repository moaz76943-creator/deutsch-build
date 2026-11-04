// Sovereign Polyglot Core - Task 3013 (Academic Research)
class Task3013Engine {
  static const int taskId = 3013;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'aufstellen';
  static const String praeteritum = 'stellte auf';
  static const String perfekt = 'hat aufgestellt';
  static const String arabicTranslation = 'رفع / فتح التنظيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[aufˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3013_aufstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt aufstellen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التنظيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
