// Sovereign Polyglot Core - Task 2384 (Software Architecture)
class Task2384Engine {
  static const int taskId = 2384;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'besprechen';
  static const String praeteritum = 'besprach';
  static const String perfekt = 'hat besprochen';
  static const String arabicTranslation = 'تأكيد / تزويد التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[beˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2384_besprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review besprechen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
