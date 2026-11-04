// Sovereign Polyglot Core - Task 2974 (Academic Research)
class Task2974Engine {
  static const int taskId = 2974;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ausplanen';
  static const String praeteritum = 'plante aus';
  static const String perfekt = 'hat ausgeplant';
  static const String arabicTranslation = 'توسيع / استخراج التخطيط (البحث الأكاديمي)';
  static const String ipaTranscription = '[ausˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2974_ausplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ausplanen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التخطيط في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
