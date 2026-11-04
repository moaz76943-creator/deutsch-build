// Sovereign Polyglot Core - Task 2372 (Software Architecture)
class Task2372Engine {
  static const int taskId = 2372;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ansprechen';
  static const String praeteritum = 'sprach an';
  static const String perfekt = 'hat angesprochen';
  static const String arabicTranslation = 'بدء / توجيه التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[anˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2372_ansprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ansprechen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
