// Sovereign Polyglot Core - Task 2245 (Software Architecture)
class Task2245Engine {
  static const int taskId = 2245;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'erlegen';
  static const String praeteritum = 'erlegte';
  static const String perfekt = 'hat erlegt';
  static const String arabicTranslation = 'إنجاز / تحقيق التأسيس (هندسة البرمجيات)';
  static const String ipaTranscription = '[erˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2245_erlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review erlegen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التأسيس في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
