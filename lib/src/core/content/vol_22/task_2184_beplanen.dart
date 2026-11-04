// Sovereign Polyglot Core - Task 2184 (Software Architecture)
class Task2184Engine {
  static const int taskId = 2184;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'beplanen';
  static const String praeteritum = 'beplante';
  static const String perfekt = 'hat beplant';
  static const String arabicTranslation = 'تأكيد / تزويد التخطيط (هندسة البرمجيات)';
  static const String ipaTranscription = '[beˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2184_beplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review beplanen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التخطيط في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
