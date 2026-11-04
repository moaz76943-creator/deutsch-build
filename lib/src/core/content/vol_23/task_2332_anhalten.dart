// Sovereign Polyglot Core - Task 2332 (Software Architecture)
class Task2332Engine {
  static const int taskId = 2332;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'anhalten';
  static const String praeteritum = 'hielt an';
  static const String perfekt = 'hat angehalten';
  static const String arabicTranslation = 'بدء / توجيه الالتزام (هندسة البرمجيات)';
  static const String ipaTranscription = '[anˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2332_anhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review anhalten.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه الالتزام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
