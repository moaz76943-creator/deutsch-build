// Sovereign Polyglot Core - Task 2513 (Software Architecture)
class Task2513Engine {
  static const int taskId = 2513;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'aufschliessen';
  static const String praeteritum = 'schloss auf';
  static const String perfekt = 'hat aufgeschlossen';
  static const String arabicTranslation = 'رفع / فتح الإبرام (هندسة البرمجيات)';
  static const String ipaTranscription = '[aufˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2513_aufschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review aufschliessen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح الإبرام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
