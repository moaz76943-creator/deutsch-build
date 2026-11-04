// Sovereign Polyglot Core - Task 2327 (Software Architecture)
class Task2327Engine {
  static const int taskId = 2327;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'umgeben';
  static const String praeteritum = 'gab um';
  static const String perfekt = 'hat umgegeben';
  static const String arabicTranslation = 'إعادة هيكلة التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[umˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2327_umgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review umgeben.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
