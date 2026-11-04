// Sovereign Polyglot Core - Task 2205 (Software Architecture)
class Task2205Engine {
  static const int taskId = 2205;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'erpruefen';
  static const String praeteritum = 'erpruefte';
  static const String perfekt = 'hat erprueft';
  static const String arabicTranslation = 'إنجاز / تحقيق التدقيق (هندسة البرمجيات)';
  static const String ipaTranscription = '[erˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2205_erpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review erpruefen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التدقيق في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
