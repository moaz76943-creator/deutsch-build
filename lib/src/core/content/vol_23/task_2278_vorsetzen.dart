// Sovereign Polyglot Core - Task 2278 (Software Architecture)
class Task2278Engine {
  static const int taskId = 2278;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vorsetzen';
  static const String praeteritum = 'setzte vor';
  static const String perfekt = 'hat vorgesetzt';
  static const String arabicTranslation = 'تقديم / تحضير التنفيذ (هندسة البرمجيات)';
  static const String ipaTranscription = '[vorˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2278_vorsetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vorsetzen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التنفيذ في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
