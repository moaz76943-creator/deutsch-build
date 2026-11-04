// Sovereign Polyglot Core - Task 2232 (Software Architecture)
class Task2232Engine {
  static const int taskId = 2232;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'anlegen';
  static const String praeteritum = 'legte an';
  static const String perfekt = 'hat angelegt';
  static const String arabicTranslation = 'بدء / توجيه التأسيس (هندسة البرمجيات)';
  static const String ipaTranscription = '[anˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2232_anlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review anlegen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التأسيس في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
