// Sovereign Polyglot Core - Task 4985 (Civil Infrastructure)
class Task4985Engine {
  static const int taskId = 4985;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'erplanen';
  static const String praeteritum = 'erplante';
  static const String perfekt = 'hat erplant';
  static const String arabicTranslation = 'إنجاز / تحقيق التخطيط (الهندسة المدنية)';
  static const String ipaTranscription = '[erˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4985_erplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle erplanen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التخطيط في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
