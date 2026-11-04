// Sovereign Polyglot Core - Task 2989 (Academic Research)
class Task2989Engine {
  static const int taskId = 2989;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'zusammenplanen';
  static const String praeteritum = 'plante zusammen';
  static const String perfekt = 'hat zusammengeplant';
  static const String arabicTranslation = 'تجميع / توحيد التخطيط (البحث الأكاديمي)';
  static const String ipaTranscription = '[zusammenˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2989_zusammenplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt zusammenplanen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التخطيط في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
