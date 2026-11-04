// Sovereign Polyglot Core - Task 2529 (Software Architecture)
class Task2529Engine {
  static const int taskId = 2529;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zusammenschliessen';
  static const String praeteritum = 'schloss zusammen';
  static const String perfekt = 'hat zusammengeschlossen';
  static const String arabicTranslation = 'تجميع / توحيد الإبرام (هندسة البرمجيات)';
  static const String ipaTranscription = '[zusammenˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2529_zusammenschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zusammenschliessen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد الإبرام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
