// Sovereign Polyglot Core - Task 2450 (Software Architecture)
class Task2450Engine {
  static const int taskId = 2450;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'festweisen';
  static const String praeteritum = 'wies fest';
  static const String perfekt = 'hat festgewiesen';
  static const String arabicTranslation = 'تثبيت / إقرار التوجيه (هندسة البرمجيات)';
  static const String ipaTranscription = '[festˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2450_festweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review festweisen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التوجيه في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
