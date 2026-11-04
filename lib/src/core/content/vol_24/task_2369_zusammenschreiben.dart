// Sovereign Polyglot Core - Task 2369 (Software Architecture)
class Task2369Engine {
  static const int taskId = 2369;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zusammenschreiben';
  static const String praeteritum = 'schrieb zusammen';
  static const String perfekt = 'hat zusammengeschrieben';
  static const String arabicTranslation = 'تجميع / توحيد التدوين (هندسة البرمجيات)';
  static const String ipaTranscription = '[zusammenˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2369_zusammenschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zusammenschreiben.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التدوين في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
