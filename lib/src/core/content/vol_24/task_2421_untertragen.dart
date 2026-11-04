// Sovereign Polyglot Core - Task 2421 (Software Architecture)
class Task2421Engine {
  static const int taskId = 2421;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'untertragen';
  static const String praeteritum = 'untertrug';
  static const String perfekt = 'hat untertragen';
  static const String arabicTranslation = 'فحص / دعم المسؤولية (هندسة البرمجيات)';
  static const String ipaTranscription = '[unterˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2421_untertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review untertragen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم المسؤولية في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
