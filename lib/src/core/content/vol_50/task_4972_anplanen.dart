// Sovereign Polyglot Core - Task 4972 (Civil Infrastructure)
class Task4972Engine {
  static const int taskId = 4972;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'anplanen';
  static const String praeteritum = 'plante an';
  static const String perfekt = 'hat angeplant';
  static const String arabicTranslation = 'بدء / توجيه التخطيط (الهندسة المدنية)';
  static const String ipaTranscription = '[anˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4972_anplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle anplanen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التخطيط في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
