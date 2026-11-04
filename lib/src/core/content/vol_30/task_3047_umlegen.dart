// Sovereign Polyglot Core - Task 3047 (Academic Research)
class Task3047Engine {
  static const int taskId = 3047;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'umlegen';
  static const String praeteritum = 'legte um';
  static const String perfekt = 'hat umgelegt';
  static const String arabicTranslation = 'إعادة هيكلة التأسيس (البحث الأكاديمي)';
  static const String ipaTranscription = '[umˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3047_umlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt umlegen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التأسيس في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
