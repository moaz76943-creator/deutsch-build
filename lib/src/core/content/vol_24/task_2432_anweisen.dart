// Sovereign Polyglot Core - Task 2432 (Software Architecture)
class Task2432Engine {
  static const int taskId = 2432;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'anweisen';
  static const String praeteritum = 'wies an';
  static const String perfekt = 'hat angewiesen';
  static const String arabicTranslation = 'بدء / توجيه التوجيه (هندسة البرمجيات)';
  static const String ipaTranscription = '[anˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2432_anweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review anweisen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التوجيه في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
