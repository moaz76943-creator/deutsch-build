// Sovereign Polyglot Core - Task 2993 (Academic Research)
class Task2993Engine {
  static const int taskId = 2993;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'aufpruefen';
  static const String praeteritum = 'pruefte auf';
  static const String perfekt = 'hat aufgeprueft';
  static const String arabicTranslation = 'رفع / فتح التدقيق (البحث الأكاديمي)';
  static const String ipaTranscription = '[aufˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2993_aufpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt aufpruefen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التدقيق في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
