// Sovereign Polyglot Core - Task 4986 (Civil Infrastructure)
class Task4986Engine {
  static const int taskId = 4986;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'durchplanen';
  static const String praeteritum = 'plante durch';
  static const String perfekt = 'hat durchgeplant';
  static const String arabicTranslation = 'إتمام شامل التخطيط (الهندسة المدنية)';
  static const String ipaTranscription = '[durchˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4986_durchplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle durchplanen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التخطيط في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
