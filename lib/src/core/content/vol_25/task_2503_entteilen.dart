// Sovereign Polyglot Core - Task 2503 (Software Architecture)
class Task2503Engine {
  static const int taskId = 2503;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entteilen';
  static const String praeteritum = 'entteilte';
  static const String perfekt = 'hat entteilt';
  static const String arabicTranslation = 'استخلاص / كشف التقسيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2503_entteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entteilen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التقسيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
