// Sovereign Polyglot Core - Task 2226 (Software Architecture)
class Task2226Engine {
  static const int taskId = 2226;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'durchstellen';
  static const String praeteritum = 'stellte durch';
  static const String perfekt = 'hat durchgestellt';
  static const String arabicTranslation = 'إتمام شامل التنظيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[durchˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2226_durchstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review durchstellen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التنظيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
