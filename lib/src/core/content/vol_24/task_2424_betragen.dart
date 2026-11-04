// Sovereign Polyglot Core - Task 2424 (Software Architecture)
class Task2424Engine {
  static const int taskId = 2424;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'betragen';
  static const String praeteritum = 'betrug';
  static const String perfekt = 'hat betragen';
  static const String arabicTranslation = 'تأكيد / تزويد المسؤولية (هندسة البرمجيات)';
  static const String ipaTranscription = '[beˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2424_betragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review betragen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد المسؤولية في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
