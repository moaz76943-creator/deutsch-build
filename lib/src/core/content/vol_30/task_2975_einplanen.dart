// Sovereign Polyglot Core - Task 2975 (Academic Research)
class Task2975Engine {
  static const int taskId = 2975;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'einplanen';
  static const String praeteritum = 'plante ein';
  static const String perfekt = 'hat eingeplant';
  static const String arabicTranslation = 'إدراج / دمج التخطيط (البحث الأكاديمي)';
  static const String ipaTranscription = '[einˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2975_einplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt einplanen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التخطيط في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
