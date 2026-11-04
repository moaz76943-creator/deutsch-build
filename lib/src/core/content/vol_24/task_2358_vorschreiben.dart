// Sovereign Polyglot Core - Task 2358 (Software Architecture)
class Task2358Engine {
  static const int taskId = 2358;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vorschreiben';
  static const String praeteritum = 'schrieb vor';
  static const String perfekt = 'hat vorgeschrieben';
  static const String arabicTranslation = 'تقديم / تحضير التدوين (هندسة البرمجيات)';
  static const String ipaTranscription = '[vorˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2358_vorschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vorschreiben.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التدوين في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
