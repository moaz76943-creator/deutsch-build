// Sovereign Polyglot Core - Task 2325 (Software Architecture)
class Task2325Engine {
  static const int taskId = 2325;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ergeben';
  static const String praeteritum = 'ergab';
  static const String perfekt = 'hat ergeben';
  static const String arabicTranslation = 'إنجاز / تحقيق التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[erˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2325_ergeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ergeben.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
