// Sovereign Polyglot Core - Task 3273 (Academic Research)
class Task3273Engine {
  static const int taskId = 3273;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'aufordnen';
  static const String praeteritum = 'ordnete auf';
  static const String perfekt = 'hat aufgeordnet';
  static const String arabicTranslation = 'رفع / فتح التصنيف (البحث الأكاديمي)';
  static const String ipaTranscription = '[aufˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3273_aufordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt aufordnen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التصنيف في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
