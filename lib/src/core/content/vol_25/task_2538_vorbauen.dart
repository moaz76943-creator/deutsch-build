// Sovereign Polyglot Core - Task 2538 (Software Architecture)
class Task2538Engine {
  static const int taskId = 2538;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vorbauen';
  static const String praeteritum = 'baute vor';
  static const String perfekt = 'hat vorgebaut';
  static const String arabicTranslation = 'تقديم / تحضير التطوير (هندسة البرمجيات)';
  static const String ipaTranscription = '[vorˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2538_vorbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vorbauen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التطوير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
