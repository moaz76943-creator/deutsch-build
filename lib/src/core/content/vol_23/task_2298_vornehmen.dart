// Sovereign Polyglot Core - Task 2298 (Software Architecture)
class Task2298Engine {
  static const int taskId = 2298;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vornehmen';
  static const String praeteritum = 'nahm vor';
  static const String perfekt = 'hat vorgenommen';
  static const String arabicTranslation = 'تقديم / تحضير الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[vorˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2298_vornehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vornehmen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
