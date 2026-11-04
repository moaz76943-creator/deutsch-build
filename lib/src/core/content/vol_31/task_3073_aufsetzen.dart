// Sovereign Polyglot Core - Task 3073 (Academic Research)
class Task3073Engine {
  static const int taskId = 3073;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'aufsetzen';
  static const String praeteritum = 'setzte auf';
  static const String perfekt = 'hat aufgesetzt';
  static const String arabicTranslation = 'رفع / فتح التنفيذ (البحث الأكاديمي)';
  static const String ipaTranscription = '[aufˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3073_aufsetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt aufsetzen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التنفيذ في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
