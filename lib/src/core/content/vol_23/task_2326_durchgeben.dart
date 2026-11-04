// Sovereign Polyglot Core - Task 2326 (Software Architecture)
class Task2326Engine {
  static const int taskId = 2326;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'durchgeben';
  static const String praeteritum = 'gab durch';
  static const String perfekt = 'hat durchgegeben';
  static const String arabicTranslation = 'إتمام شامل التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[durchˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2326_durchgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review durchgeben.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
