// Sovereign Polyglot Core - Task 2297 (Software Architecture)
class Task2297Engine {
  static const int taskId = 2297;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'nachnehmen';
  static const String praeteritum = 'nahm nach';
  static const String perfekt = 'hat nachgenommen';
  static const String arabicTranslation = 'تدقيق / متابعة الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[nachˈˈneːmən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2297_nachnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review nachnehmen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
