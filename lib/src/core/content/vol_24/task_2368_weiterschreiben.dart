// Sovereign Polyglot Core - Task 2368 (Software Architecture)
class Task2368Engine {
  static const int taskId = 2368;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'weiterschreiben';
  static const String praeteritum = 'schrieb weiter';
  static const String perfekt = 'hat weitergeschrieben';
  static const String arabicTranslation = 'مواصلة / تمرير التدوين (هندسة البرمجيات)';
  static const String ipaTranscription = '[weiterˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2368_weiterschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review weiterschreiben.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التدوين في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
