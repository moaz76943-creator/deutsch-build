// Sovereign Polyglot Core - Task 2365 (Software Architecture)
class Task2365Engine {
  static const int taskId = 2365;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'erschreiben';
  static const String praeteritum = 'erschrieb';
  static const String perfekt = 'hat erschrieben';
  static const String arabicTranslation = 'إنجاز / تحقيق التدوين (هندسة البرمجيات)';
  static const String ipaTranscription = '[erˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2365_erschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review erschreiben.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التدوين في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
