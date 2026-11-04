// Sovereign Polyglot Core - Task 2373 (Software Architecture)
class Task2373Engine {
  static const int taskId = 2373;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'aufsprechen';
  static const String praeteritum = 'sprach auf';
  static const String perfekt = 'hat aufgesprochen';
  static const String arabicTranslation = 'رفع / فتح التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[aufˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2373_aufsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review aufsprechen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
