// Sovereign Polyglot Core - Task 2305 (Software Architecture)
class Task2305Engine {
  static const int taskId = 2305;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ernehmen';
  static const String praeteritum = 'ernahm';
  static const String perfekt = 'hat ernommen';
  static const String arabicTranslation = 'إنجاز / تحقيق الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[erˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2305_ernehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ernehmen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
