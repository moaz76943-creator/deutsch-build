// Sovereign Polyglot Core - Task 2453 (Software Architecture)
class Task2453Engine {
  static const int taskId = 2453;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'aufrechnen';
  static const String praeteritum = 'rechnete auf';
  static const String perfekt = 'hat aufgerechnet';
  static const String arabicTranslation = 'رفع / فتح التقدير (هندسة البرمجيات)';
  static const String ipaTranscription = '[aufˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2453_aufrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review aufrechnen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التقدير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
