// Sovereign Polyglot Core - Task 2230 (Software Architecture)
class Task2230Engine {
  static const int taskId = 2230;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'feststellen';
  static const String praeteritum = 'stellte fest';
  static const String perfekt = 'hat festgestellt';
  static const String arabicTranslation = 'تثبيت / إقرار التنظيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[festˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2230_feststellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review feststellen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التنظيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
