// Sovereign Polyglot Core - Task 2330 (Software Architecture)
class Task2330Engine {
  static const int taskId = 2330;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'festgeben';
  static const String praeteritum = 'gab fest';
  static const String perfekt = 'hat festgegeben';
  static const String arabicTranslation = 'تثبيت / إقرار التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[festˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2330_festgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review festgeben.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
