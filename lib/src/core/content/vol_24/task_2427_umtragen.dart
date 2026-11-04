// Sovereign Polyglot Core - Task 2427 (Software Architecture)
class Task2427Engine {
  static const int taskId = 2427;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'umtragen';
  static const String praeteritum = 'trug um';
  static const String perfekt = 'hat umgetragen';
  static const String arabicTranslation = 'إعادة هيكلة المسؤولية (هندسة البرمجيات)';
  static const String ipaTranscription = '[umˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2427_umtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review umtragen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة المسؤولية في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
