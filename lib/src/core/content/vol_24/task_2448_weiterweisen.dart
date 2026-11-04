// Sovereign Polyglot Core - Task 2448 (Software Architecture)
class Task2448Engine {
  static const int taskId = 2448;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'weiterweisen';
  static const String praeteritum = 'wies weiter';
  static const String perfekt = 'hat weitergewiesen';
  static const String arabicTranslation = 'مواصلة / تمرير التوجيه (هندسة البرمجيات)';
  static const String ipaTranscription = '[weiterˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2448_weiterweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review weiterweisen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التوجيه في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
