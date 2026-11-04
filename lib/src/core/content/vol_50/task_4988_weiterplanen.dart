// Sovereign Polyglot Core - Task 4988 (Civil Infrastructure)
class Task4988Engine {
  static const int taskId = 4988;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'weiterplanen';
  static const String praeteritum = 'plante weiter';
  static const String perfekt = 'hat weitergeplant';
  static const String arabicTranslation = 'مواصلة / تمرير التخطيط (الهندسة المدنية)';
  static const String ipaTranscription = '[weiterˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4988_weiterplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle weiterplanen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التخطيط في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
