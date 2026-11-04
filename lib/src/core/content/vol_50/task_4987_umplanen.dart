// Sovereign Polyglot Core - Task 4987 (Civil Infrastructure)
class Task4987Engine {
  static const int taskId = 4987;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'umplanen';
  static const String praeteritum = 'plante um';
  static const String perfekt = 'hat umgeplant';
  static const String arabicTranslation = 'إعادة هيكلة التخطيط (الهندسة المدنية)';
  static const String ipaTranscription = '[umˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4987_umplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle umplanen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التخطيط في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
