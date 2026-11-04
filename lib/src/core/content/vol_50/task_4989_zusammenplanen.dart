// Sovereign Polyglot Core - Task 4989 (Civil Infrastructure)
class Task4989Engine {
  static const int taskId = 4989;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'zusammenplanen';
  static const String praeteritum = 'plante zusammen';
  static const String perfekt = 'hat zusammengeplant';
  static const String arabicTranslation = 'تجميع / توحيد التخطيط (الهندسة المدنية)';
  static const String ipaTranscription = '[zusammenˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4989_zusammenplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle zusammenplanen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التخطيط في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
