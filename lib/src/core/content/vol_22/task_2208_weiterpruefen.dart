// Sovereign Polyglot Core - Task 2208 (Software Architecture)
class Task2208Engine {
  static const int taskId = 2208;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'weiterpruefen';
  static const String praeteritum = 'pruefte weiter';
  static const String perfekt = 'hat weitergeprueft';
  static const String arabicTranslation = 'مواصلة / تمرير التدقيق (هندسة البرمجيات)';
  static const String ipaTranscription = '[weiterˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2208_weiterpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review weiterpruefen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التدقيق في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
