// Sovereign Polyglot Core - Task 2187 (Software Architecture)
class Task2187Engine {
  static const int taskId = 2187;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'umplanen';
  static const String praeteritum = 'plante um';
  static const String perfekt = 'hat umgeplant';
  static const String arabicTranslation = 'إعادة هيكلة التخطيط (هندسة البرمجيات)';
  static const String ipaTranscription = '[umˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2187_umplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review umplanen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التخطيط في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
