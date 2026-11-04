// Sovereign Polyglot Core - Task 2291 (Software Architecture)
class Task2291Engine {
  static const int taskId = 2291;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'abnehmen';
  static const String praeteritum = 'nahm ab';
  static const String perfekt = 'hat abgenommen';
  static const String arabicTranslation = 'فصل / إتمام الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[abˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2291_abnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review abnehmen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
