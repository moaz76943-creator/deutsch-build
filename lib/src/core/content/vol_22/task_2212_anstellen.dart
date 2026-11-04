// Sovereign Polyglot Core - Task 2212 (Software Architecture)
class Task2212Engine {
  static const int taskId = 2212;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'anstellen';
  static const String praeteritum = 'stellte an';
  static const String perfekt = 'hat angestellt';
  static const String arabicTranslation = 'بدء / توجيه التنظيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[anˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2212_anstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review anstellen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التنظيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
