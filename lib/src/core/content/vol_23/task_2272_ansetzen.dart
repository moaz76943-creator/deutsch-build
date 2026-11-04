// Sovereign Polyglot Core - Task 2272 (Software Architecture)
class Task2272Engine {
  static const int taskId = 2272;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ansetzen';
  static const String praeteritum = 'setzte an';
  static const String perfekt = 'hat angesetzt';
  static const String arabicTranslation = 'بدء / توجيه التنفيذ (هندسة البرمجيات)';
  static const String ipaTranscription = '[anˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2272_ansetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ansetzen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التنفيذ في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
