// Sovereign Polyglot Core - Task 2238 (Software Architecture)
class Task2238Engine {
  static const int taskId = 2238;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vorlegen';
  static const String praeteritum = 'legte vor';
  static const String perfekt = 'hat vorgelegt';
  static const String arabicTranslation = 'تقديم / تحضير التأسيس (هندسة البرمجيات)';
  static const String ipaTranscription = '[vorˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2238_vorlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vorlegen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التأسيس في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
