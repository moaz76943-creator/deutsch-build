// Sovereign Polyglot Core - Task 2313 (Software Architecture)
class Task2313Engine {
  static const int taskId = 2313;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'aufgeben';
  static const String praeteritum = 'gab auf';
  static const String perfekt = 'hat aufgegeben';
  static const String arabicTranslation = 'رفع / فتح التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[aufˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2313_aufgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review aufgeben.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
