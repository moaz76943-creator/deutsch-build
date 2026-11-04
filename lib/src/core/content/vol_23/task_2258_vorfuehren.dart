// Sovereign Polyglot Core - Task 2258 (Software Architecture)
class Task2258Engine {
  static const int taskId = 2258;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vorfuehren';
  static const String praeteritum = 'fuehrte vor';
  static const String perfekt = 'hat vorgefuehrt';
  static const String arabicTranslation = 'تقديم / تحضير الإدارة (هندسة البرمجيات)';
  static const String ipaTranscription = '[vorˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2258_vorfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vorfuehren.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير الإدارة في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
