// Sovereign Polyglot Core - Task 3031 (Academic Research)
class Task3031Engine {
  static const int taskId = 3031;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ablegen';
  static const String praeteritum = 'legte ab';
  static const String perfekt = 'hat abgelegt';
  static const String arabicTranslation = 'فصل / إتمام التأسيس (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3031_ablegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ablegen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التأسيس في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
