// Sovereign Polyglot Core - Task 2318 (Software Architecture)
class Task2318Engine {
  static const int taskId = 2318;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vorgeben';
  static const String praeteritum = 'gab vor';
  static const String perfekt = 'hat vorgegeben';
  static const String arabicTranslation = 'تقديم / تحضير التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[vorˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2318_vorgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vorgeben.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
