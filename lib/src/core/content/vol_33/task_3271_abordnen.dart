// Sovereign Polyglot Core - Task 3271 (Academic Research)
class Task3271Engine {
  static const int taskId = 3271;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'abordnen';
  static const String praeteritum = 'ordnete ab';
  static const String perfekt = 'hat abgeordnet';
  static const String arabicTranslation = 'فصل / إتمام التصنيف (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3271_abordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt abordnen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التصنيف في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
