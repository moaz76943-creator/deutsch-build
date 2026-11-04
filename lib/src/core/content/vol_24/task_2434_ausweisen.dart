// Sovereign Polyglot Core - Task 2434 (Software Architecture)
class Task2434Engine {
  static const int taskId = 2434;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ausweisen';
  static const String praeteritum = 'wies aus';
  static const String perfekt = 'hat ausgewiesen';
  static const String arabicTranslation = 'توسيع / استخراج التوجيه (هندسة البرمجيات)';
  static const String ipaTranscription = '[ausˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2434_ausweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ausweisen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التوجيه في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
