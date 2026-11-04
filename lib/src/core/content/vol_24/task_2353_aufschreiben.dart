// Sovereign Polyglot Core - Task 2353 (Software Architecture)
class Task2353Engine {
  static const int taskId = 2353;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'aufschreiben';
  static const String praeteritum = 'schrieb auf';
  static const String perfekt = 'hat aufgeschrieben';
  static const String arabicTranslation = 'رفع / فتح التدوين (هندسة البرمجيات)';
  static const String ipaTranscription = '[aufˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2353_aufschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review aufschreiben.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التدوين في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
