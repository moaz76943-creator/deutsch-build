// Sovereign Polyglot Core - Task 4982 (Civil Infrastructure)
class Task4982Engine {
  static const int taskId = 4982;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'verplanen';
  static const String praeteritum = 'verplante';
  static const String perfekt = 'hat verplant';
  static const String arabicTranslation = 'توثيق / معالجة التخطيط (الهندسة المدنية)';
  static const String ipaTranscription = '[verˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4982_verplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle verplanen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التخطيط في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
