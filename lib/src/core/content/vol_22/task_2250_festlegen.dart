// Sovereign Polyglot Core - Task 2250 (Software Architecture)
class Task2250Engine {
  static const int taskId = 2250;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'festlegen';
  static const String praeteritum = 'legte fest';
  static const String perfekt = 'hat festgelegt';
  static const String arabicTranslation = 'تثبيت / إقرار التأسيس (هندسة البرمجيات)';
  static const String ipaTranscription = '[festˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2250_festlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review festlegen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التأسيس في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
