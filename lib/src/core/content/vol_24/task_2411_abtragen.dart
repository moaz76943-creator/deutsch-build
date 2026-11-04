// Sovereign Polyglot Core - Task 2411 (Software Architecture)
class Task2411Engine {
  static const int taskId = 2411;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'abtragen';
  static const String praeteritum = 'trug ab';
  static const String perfekt = 'hat abgetragen';
  static const String arabicTranslation = 'فصل / إتمام المسؤولية (هندسة البرمجيات)';
  static const String ipaTranscription = '[abˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2411_abtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review abtragen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام المسؤولية في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
