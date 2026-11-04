// Sovereign Polyglot Core - Task 4974 (Civil Infrastructure)
class Task4974Engine {
  static const int taskId = 4974;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'ausplanen';
  static const String praeteritum = 'plante aus';
  static const String perfekt = 'hat ausgeplant';
  static const String arabicTranslation = 'توسيع / استخراج التخطيط (الهندسة المدنية)';
  static const String ipaTranscription = '[ausˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4974_ausplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle ausplanen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التخطيط في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
