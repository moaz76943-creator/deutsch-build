// Sovereign Polyglot Core - Task 2337 (Software Architecture)
class Task2337Engine {
  static const int taskId = 2337;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'nachhalten';
  static const String praeteritum = 'hielt nach';
  static const String perfekt = 'hat nachgehalten';
  static const String arabicTranslation = 'تدقيق / متابعة الالتزام (هندسة البرمجيات)';
  static const String ipaTranscription = '[nachˈˈhaltn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2337_nachhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review nachhalten.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة الالتزام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
