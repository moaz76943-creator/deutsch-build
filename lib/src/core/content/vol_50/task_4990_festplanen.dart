// Sovereign Polyglot Core - Task 4990 (Civil Infrastructure)
class Task4990Engine {
  static const int taskId = 4990;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'festplanen';
  static const String praeteritum = 'plante fest';
  static const String perfekt = 'hat festgeplant';
  static const String arabicTranslation = 'تثبيت / إقرار التخطيط (الهندسة المدنية)';
  static const String ipaTranscription = '[festˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4990_festplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle festplanen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التخطيط في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
