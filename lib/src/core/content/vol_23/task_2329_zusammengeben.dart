// Sovereign Polyglot Core - Task 2329 (Software Architecture)
class Task2329Engine {
  static const int taskId = 2329;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zusammengeben';
  static const String praeteritum = 'gab zusammen';
  static const String perfekt = 'hat zusammengegeben';
  static const String arabicTranslation = 'تجميع / توحيد التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[zusammenˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2329_zusammengeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zusammengeben.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
