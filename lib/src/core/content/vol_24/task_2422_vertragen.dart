// Sovereign Polyglot Core - Task 2422 (Software Architecture)
class Task2422Engine {
  static const int taskId = 2422;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vertragen';
  static const String praeteritum = 'vertrug';
  static const String perfekt = 'hat vertragen';
  static const String arabicTranslation = 'توثيق / معالجة المسؤولية (هندسة البرمجيات)';
  static const String ipaTranscription = '[verˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2422_vertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vertragen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة المسؤولية في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
