// Sovereign Polyglot Core - Task 3035 (Academic Research)
class Task3035Engine {
  static const int taskId = 3035;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'einlegen';
  static const String praeteritum = 'legte ein';
  static const String perfekt = 'hat eingelegt';
  static const String arabicTranslation = 'إدراج / دمج التأسيس (البحث الأكاديمي)';
  static const String ipaTranscription = '[einˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3035_einlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt einlegen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التأسيس في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
