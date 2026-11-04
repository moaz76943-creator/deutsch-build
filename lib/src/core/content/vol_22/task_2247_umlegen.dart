// Sovereign Polyglot Core - Task 2247 (Software Architecture)
class Task2247Engine {
  static const int taskId = 2247;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'umlegen';
  static const String praeteritum = 'legte um';
  static const String perfekt = 'hat umgelegt';
  static const String arabicTranslation = 'إعادة هيكلة التأسيس (هندسة البرمجيات)';
  static const String ipaTranscription = '[umˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2247_umlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review umlegen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التأسيس في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
