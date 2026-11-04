// Sovereign Polyglot Core - Task 2185 (Software Architecture)
class Task2185Engine {
  static const int taskId = 2185;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'erplanen';
  static const String praeteritum = 'erplante';
  static const String perfekt = 'hat erplant';
  static const String arabicTranslation = 'إنجاز / تحقيق التخطيط (هندسة البرمجيات)';
  static const String ipaTranscription = '[erˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2185_erplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review erplanen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التخطيط في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
