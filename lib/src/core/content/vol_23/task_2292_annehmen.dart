// Sovereign Polyglot Core - Task 2292 (Software Architecture)
class Task2292Engine {
  static const int taskId = 2292;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'annehmen';
  static const String praeteritum = 'nahm an';
  static const String perfekt = 'hat angenommen';
  static const String arabicTranslation = 'بدء / توجيه الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[anˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2292_annehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review annehmen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
