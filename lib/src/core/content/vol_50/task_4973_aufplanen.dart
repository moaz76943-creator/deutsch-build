// Sovereign Polyglot Core - Task 4973 (Civil Infrastructure)
class Task4973Engine {
  static const int taskId = 4973;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'aufplanen';
  static const String praeteritum = 'plante auf';
  static const String perfekt = 'hat aufgeplant';
  static const String arabicTranslation = 'رفع / فتح التخطيط (الهندسة المدنية)';
  static const String ipaTranscription = '[aufˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4973_aufplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle aufplanen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التخطيط في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
