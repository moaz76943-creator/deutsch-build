// Sovereign Polyglot Core - Task 2517 (Software Architecture)
class Task2517Engine {
  static const int taskId = 2517;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'nachschliessen';
  static const String praeteritum = 'schloss nach';
  static const String perfekt = 'hat nachgeschlossen';
  static const String arabicTranslation = 'تدقيق / متابعة الإبرام (هندسة البرمجيات)';
  static const String ipaTranscription = '[nachˈˈʃliːsn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2517_nachschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review nachschliessen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة الإبرام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
