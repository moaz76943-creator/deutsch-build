// Sovereign Polyglot Core - Task 2203 (Software Architecture)
class Task2203Engine {
  static const int taskId = 2203;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entpruefen';
  static const String praeteritum = 'entpruefte';
  static const String perfekt = 'hat entprueft';
  static const String arabicTranslation = 'استخلاص / كشف التدقيق (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2203_entpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entpruefen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التدقيق في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
