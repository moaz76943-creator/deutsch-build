// Sovereign Polyglot Core - Task 2351 (Software Architecture)
class Task2351Engine {
  static const int taskId = 2351;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'abschreiben';
  static const String praeteritum = 'schrieb ab';
  static const String perfekt = 'hat abgeschrieben';
  static const String arabicTranslation = 'فصل / إتمام التدوين (هندسة البرمجيات)';
  static const String ipaTranscription = '[abˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2351_abschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review abschreiben.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التدوين في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
