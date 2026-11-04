// Sovereign Polyglot Core - Task 2204 (Software Architecture)
class Task2204Engine {
  static const int taskId = 2204;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'bepruefen';
  static const String praeteritum = 'bepruefte';
  static const String perfekt = 'hat beprueft';
  static const String arabicTranslation = 'تأكيد / تزويد التدقيق (هندسة البرمجيات)';
  static const String ipaTranscription = '[beˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2204_bepruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review bepruefen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التدقيق في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
