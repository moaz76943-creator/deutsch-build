// Sovereign Polyglot Core - Task 2315 (Software Architecture)
class Task2315Engine {
  static const int taskId = 2315;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'eingeben';
  static const String praeteritum = 'gab ein';
  static const String perfekt = 'hat eingegeben';
  static const String arabicTranslation = 'إدراج / دمج التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2315_eingeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review eingeben.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
