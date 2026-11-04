// Sovereign Polyglot Core - Task 2338 (Software Architecture)
class Task2338Engine {
  static const int taskId = 2338;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vorhalten';
  static const String praeteritum = 'hielt vor';
  static const String perfekt = 'hat vorgehalten';
  static const String arabicTranslation = 'تقديم / تحضير الالتزام (هندسة البرمجيات)';
  static const String ipaTranscription = '[vorˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2338_vorhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vorhalten.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير الالتزام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
