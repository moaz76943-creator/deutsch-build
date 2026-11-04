// Sovereign Polyglot Core - Task 4977 (Civil Infrastructure)
class Task4977Engine {
  static const int taskId = 4977;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'nachplanen';
  static const String praeteritum = 'plante nach';
  static const String perfekt = 'hat nachgeplant';
  static const String arabicTranslation = 'تدقيق / متابعة التخطيط (الهندسة المدنية)';
  static const String ipaTranscription = '[nachˈˈplaːnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4977_nachplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle nachplanen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التخطيط في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
