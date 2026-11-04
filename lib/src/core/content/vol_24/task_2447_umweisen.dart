// Sovereign Polyglot Core - Task 2447 (Software Architecture)
class Task2447Engine {
  static const int taskId = 2447;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'umweisen';
  static const String praeteritum = 'wies um';
  static const String perfekt = 'hat umgewiesen';
  static const String arabicTranslation = 'إعادة هيكلة التوجيه (هندسة البرمجيات)';
  static const String ipaTranscription = '[umˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2447_umweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review umweisen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التوجيه في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
