// Sovereign Polyglot Core - Task 3274 (Academic Research)
class Task3274Engine {
  static const int taskId = 3274;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ausordnen';
  static const String praeteritum = 'ordnete aus';
  static const String perfekt = 'hat ausgeordnet';
  static const String arabicTranslation = 'توسيع / استخراج التصنيف (البحث الأكاديمي)';
  static const String ipaTranscription = '[ausˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3274_ausordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ausordnen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التصنيف في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
