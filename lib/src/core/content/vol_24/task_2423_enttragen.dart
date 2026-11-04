// Sovereign Polyglot Core - Task 2423 (Software Architecture)
class Task2423Engine {
  static const int taskId = 2423;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'enttragen';
  static const String praeteritum = 'enttrug';
  static const String perfekt = 'hat enttragen';
  static const String arabicTranslation = 'استخلاص / كشف المسؤولية (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2423_enttragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review enttragen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف المسؤولية في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
