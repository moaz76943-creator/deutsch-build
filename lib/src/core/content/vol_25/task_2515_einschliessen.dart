// Sovereign Polyglot Core - Task 2515 (Software Architecture)
class Task2515Engine {
  static const int taskId = 2515;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'einschliessen';
  static const String praeteritum = 'schloss ein';
  static const String perfekt = 'hat eingeschlossen';
  static const String arabicTranslation = 'إدراج / دمج الإبرام (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2515_einschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review einschliessen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الإبرام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
