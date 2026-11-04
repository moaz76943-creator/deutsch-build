// Sovereign Polyglot Core - Task 2198 (Software Architecture)
class Task2198Engine {
  static const int taskId = 2198;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vorpruefen';
  static const String praeteritum = 'pruefte vor';
  static const String perfekt = 'hat vorgeprueft';
  static const String arabicTranslation = 'تقديم / تحضير التدقيق (هندسة البرمجيات)';
  static const String ipaTranscription = '[vorˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2198_vorpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vorpruefen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التدقيق في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
