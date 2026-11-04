// Sovereign Polyglot Core - Task 2178 (Software Architecture)
class Task2178Engine {
  static const int taskId = 2178;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vorplanen';
  static const String praeteritum = 'plante vor';
  static const String perfekt = 'hat vorgeplant';
  static const String arabicTranslation = 'تقديم / تحضير التخطيط (هندسة البرمجيات)';
  static const String ipaTranscription = '[vorˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2178_vorplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vorplanen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التخطيط في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
