// Sovereign Polyglot Core - Task 2973 (Academic Research)
class Task2973Engine {
  static const int taskId = 2973;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'aufplanen';
  static const String praeteritum = 'plante auf';
  static const String perfekt = 'hat aufgeplant';
  static const String arabicTranslation = 'رفع / فتح التخطيط (البحث الأكاديمي)';
  static const String ipaTranscription = '[aufˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2973_aufplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt aufplanen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التخطيط في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
