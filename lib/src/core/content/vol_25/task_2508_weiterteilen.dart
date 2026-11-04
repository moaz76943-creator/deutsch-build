// Sovereign Polyglot Core - Task 2508 (Software Architecture)
class Task2508Engine {
  static const int taskId = 2508;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'weiterteilen';
  static const String praeteritum = 'teilte weiter';
  static const String perfekt = 'hat weitergeteilt';
  static const String arabicTranslation = 'مواصلة / تمرير التقسيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[weiterˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2508_weiterteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review weiterteilen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التقسيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
