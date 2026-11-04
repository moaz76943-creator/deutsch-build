// Sovereign Polyglot Core - Task 2236 (Software Architecture)
class Task2236Engine {
  static const int taskId = 2236;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'mitlegen';
  static const String praeteritum = 'legte mit';
  static const String perfekt = 'hat mitgelegt';
  static const String arabicTranslation = 'مشاركة / تنسيق التأسيس (هندسة البرمجيات)';
  static const String ipaTranscription = '[mitˈˈleːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2236_mitlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review mitlegen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التأسيس في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
