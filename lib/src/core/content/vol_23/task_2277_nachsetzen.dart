// Sovereign Polyglot Core - Task 2277 (Software Architecture)
class Task2277Engine {
  static const int taskId = 2277;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'nachsetzen';
  static const String praeteritum = 'setzte nach';
  static const String perfekt = 'hat nachgesetzt';
  static const String arabicTranslation = 'تدقيق / متابعة التنفيذ (هندسة البرمجيات)';
  static const String ipaTranscription = '[nachˈˈzɛtsn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2277_nachsetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review nachsetzen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التنفيذ في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
