// Sovereign Polyglot Core - Task 3280 (Academic Research)
class Task3280Engine {
  static const int taskId = 3280;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ueberordnen';
  static const String praeteritum = 'ueberordnete';
  static const String perfekt = 'hat ueberordnet';
  static const String arabicTranslation = 'مراجعة / نقل التصنيف (البحث الأكاديمي)';
  static const String ipaTranscription = '[ueberˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3280_ueberordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ueberordnen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التصنيف في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
