// Sovereign Polyglot Core - Task 2314 (Software Architecture)
class Task2314Engine {
  static const int taskId = 2314;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ausgeben';
  static const String praeteritum = 'gab aus';
  static const String perfekt = 'hat ausgegeben';
  static const String arabicTranslation = 'توسيع / استخراج التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[ausˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2314_ausgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ausgeben.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
