// Sovereign Polyglot Core - Task 2223 (Software Architecture)
class Task2223Engine {
  static const int taskId = 2223;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entstellen';
  static const String praeteritum = 'entstellte';
  static const String perfekt = 'hat entstellt';
  static const String arabicTranslation = 'استخلاص / كشف التنظيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2223_entstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entstellen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التنظيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
