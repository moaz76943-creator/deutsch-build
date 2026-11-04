// Sovereign Polyglot Core - Task 4980 (Civil Infrastructure)
class Task4980Engine {
  static const int taskId = 4980;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'ueberplanen';
  static const String praeteritum = 'ueberplante';
  static const String perfekt = 'hat ueberplant';
  static const String arabicTranslation = 'مراجعة / نقل التخطيط (الهندسة المدنية)';
  static const String ipaTranscription = '[ueberˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4980_ueberplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle ueberplanen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التخطيط في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
