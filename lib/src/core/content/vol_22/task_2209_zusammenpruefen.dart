// Sovereign Polyglot Core - Task 2209 (Software Architecture)
class Task2209Engine {
  static const int taskId = 2209;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zusammenpruefen';
  static const String praeteritum = 'pruefte zusammen';
  static const String perfekt = 'hat zusammengeprueft';
  static const String arabicTranslation = 'تجميع / توحيد التدقيق (هندسة البرمجيات)';
  static const String ipaTranscription = '[zusammenˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2209_zusammenpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zusammenpruefen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التدقيق في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
