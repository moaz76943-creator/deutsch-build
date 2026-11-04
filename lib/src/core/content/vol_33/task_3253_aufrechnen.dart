// Sovereign Polyglot Core - Task 3253 (Academic Research)
class Task3253Engine {
  static const int taskId = 3253;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'aufrechnen';
  static const String praeteritum = 'rechnete auf';
  static const String perfekt = 'hat aufgerechnet';
  static const String arabicTranslation = 'رفع / فتح التقدير (البحث الأكاديمي)';
  static const String ipaTranscription = '[aufˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3253_aufrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt aufrechnen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التقدير في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
