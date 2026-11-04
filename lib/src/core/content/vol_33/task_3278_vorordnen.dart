// Sovereign Polyglot Core - Task 3278 (Academic Research)
class Task3278Engine {
  static const int taskId = 3278;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'vorordnen';
  static const String praeteritum = 'ordnete vor';
  static const String perfekt = 'hat vorgeordnet';
  static const String arabicTranslation = 'تقديم / تحضير التصنيف (البحث الأكاديمي)';
  static const String ipaTranscription = '[vorˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3278_vorordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt vorordnen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التصنيف في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
