// Sovereign Polyglot Core - Task 2535 (Software Architecture)
class Task2535Engine {
  static const int taskId = 2535;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'einbauen';
  static const String praeteritum = 'baute ein';
  static const String perfekt = 'hat eingebaut';
  static const String arabicTranslation = 'إدراج / دمج التطوير (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2535_einbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review einbauen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التطوير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
