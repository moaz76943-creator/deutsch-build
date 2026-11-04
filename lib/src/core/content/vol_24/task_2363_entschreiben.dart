// Sovereign Polyglot Core - Task 2363 (Software Architecture)
class Task2363Engine {
  static const int taskId = 2363;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entschreiben';
  static const String praeteritum = 'entschrieb';
  static const String perfekt = 'hat entschrieben';
  static const String arabicTranslation = 'استخلاص / كشف التدوين (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2363_entschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entschreiben.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التدوين في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
