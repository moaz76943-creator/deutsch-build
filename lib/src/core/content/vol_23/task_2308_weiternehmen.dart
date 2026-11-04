// Sovereign Polyglot Core - Task 2308 (Software Architecture)
class Task2308Engine {
  static const int taskId = 2308;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'weiternehmen';
  static const String praeteritum = 'nahm weiter';
  static const String perfekt = 'hat weitergenommen';
  static const String arabicTranslation = 'مواصلة / تمرير الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[weiterˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2308_weiternehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review weiternehmen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
