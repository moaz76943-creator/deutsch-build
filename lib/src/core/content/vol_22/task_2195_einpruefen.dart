// Sovereign Polyglot Core - Task 2195 (Software Architecture)
class Task2195Engine {
  static const int taskId = 2195;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'einpruefen';
  static const String praeteritum = 'pruefte ein';
  static const String perfekt = 'hat eingeprueft';
  static const String arabicTranslation = 'إدراج / دمج التدقيق (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2195_einpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review einpruefen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التدقيق في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
