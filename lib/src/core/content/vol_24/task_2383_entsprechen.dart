// Sovereign Polyglot Core - Task 2383 (Software Architecture)
class Task2383Engine {
  static const int taskId = 2383;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entsprechen';
  static const String praeteritum = 'entsprach';
  static const String perfekt = 'hat entsprochen';
  static const String arabicTranslation = 'استخلاص / كشف التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2383_entsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entsprechen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
