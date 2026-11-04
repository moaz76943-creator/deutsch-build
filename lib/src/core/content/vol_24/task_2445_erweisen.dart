// Sovereign Polyglot Core - Task 2445 (Software Architecture)
class Task2445Engine {
  static const int taskId = 2445;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'erweisen';
  static const String praeteritum = 'erwies';
  static const String perfekt = 'hat erwiesen';
  static const String arabicTranslation = 'إنجاز / تحقيق التوجيه (هندسة البرمجيات)';
  static const String ipaTranscription = '[erˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2445_erweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review erweisen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التوجيه في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
