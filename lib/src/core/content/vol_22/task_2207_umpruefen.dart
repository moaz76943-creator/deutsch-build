// Sovereign Polyglot Core - Task 2207 (Software Architecture)
class Task2207Engine {
  static const int taskId = 2207;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'umpruefen';
  static const String praeteritum = 'pruefte um';
  static const String perfekt = 'hat umgeprueft';
  static const String arabicTranslation = 'إعادة هيكلة التدقيق (هندسة البرمجيات)';
  static const String ipaTranscription = '[umˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2207_umpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review umpruefen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التدقيق في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
