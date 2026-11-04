// Sovereign Polyglot Core - Task 2323 (Software Architecture)
class Task2323Engine {
  static const int taskId = 2323;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entgeben';
  static const String praeteritum = 'entgab';
  static const String perfekt = 'hat entgeben';
  static const String arabicTranslation = 'استخلاص / كشف التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2323_entgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entgeben.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
