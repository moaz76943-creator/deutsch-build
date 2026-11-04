// Sovereign Polyglot Core - Task 2224 (Software Architecture)
class Task2224Engine {
  static const int taskId = 2224;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'bestellen';
  static const String praeteritum = 'bestellte';
  static const String perfekt = 'hat bestellt';
  static const String arabicTranslation = 'تأكيد / تزويد التنظيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[beˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2224_bestellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review bestellen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التنظيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
