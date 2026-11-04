// Sovereign Polyglot Core - Task 2972 (Academic Research)
class Task2972Engine {
  static const int taskId = 2972;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'anplanen';
  static const String praeteritum = 'plante an';
  static const String perfekt = 'hat angeplant';
  static const String arabicTranslation = 'بدء / توجيه التخطيط (البحث الأكاديمي)';
  static const String ipaTranscription = '[anˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2972_anplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt anplanen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التخطيط في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
