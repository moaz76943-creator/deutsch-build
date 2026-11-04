// Sovereign Polyglot Core - Task 2367 (Software Architecture)
class Task2367Engine {
  static const int taskId = 2367;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'umschreiben';
  static const String praeteritum = 'schrieb um';
  static const String perfekt = 'hat umgeschrieben';
  static const String arabicTranslation = 'إعادة هيكلة التدوين (هندسة البرمجيات)';
  static const String ipaTranscription = '[umˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2367_umschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review umschreiben.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التدوين في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
