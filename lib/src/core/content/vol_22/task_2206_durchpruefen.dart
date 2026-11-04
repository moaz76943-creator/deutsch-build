// Sovereign Polyglot Core - Task 2206 (Software Architecture)
class Task2206Engine {
  static const int taskId = 2206;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'durchpruefen';
  static const String praeteritum = 'pruefte durch';
  static const String perfekt = 'hat durchgeprueft';
  static const String arabicTranslation = 'إتمام شامل التدقيق (هندسة البرمجيات)';
  static const String ipaTranscription = '[durchˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2206_durchpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review durchpruefen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التدقيق في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
