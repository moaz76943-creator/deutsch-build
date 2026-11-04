// Sovereign Polyglot Core - Task 2310 (Software Architecture)
class Task2310Engine {
  static const int taskId = 2310;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'festnehmen';
  static const String praeteritum = 'nahm fest';
  static const String perfekt = 'hat festgenommen';
  static const String arabicTranslation = 'تثبيت / إقرار الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[festˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2310_festnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review festnehmen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
