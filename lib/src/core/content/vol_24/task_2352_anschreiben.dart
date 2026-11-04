// Sovereign Polyglot Core - Task 2352 (Software Architecture)
class Task2352Engine {
  static const int taskId = 2352;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'anschreiben';
  static const String praeteritum = 'schrieb an';
  static const String perfekt = 'hat angeschrieben';
  static const String arabicTranslation = 'بدء / توجيه التدوين (هندسة البرمجيات)';
  static const String ipaTranscription = '[anˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2352_anschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review anschreiben.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التدوين في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
