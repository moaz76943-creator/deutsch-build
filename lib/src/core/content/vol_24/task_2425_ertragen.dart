// Sovereign Polyglot Core - Task 2425 (Software Architecture)
class Task2425Engine {
  static const int taskId = 2425;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ertragen';
  static const String praeteritum = 'ertrug';
  static const String perfekt = 'hat ertragen';
  static const String arabicTranslation = 'إنجاز / تحقيق المسؤولية (هندسة البرمجيات)';
  static const String ipaTranscription = '[erˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2425_ertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ertragen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق المسؤولية في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
