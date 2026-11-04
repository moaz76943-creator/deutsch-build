// Sovereign Polyglot Core - Task 2523 (Software Architecture)
class Task2523Engine {
  static const int taskId = 2523;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entschliessen';
  static const String praeteritum = 'entschloss';
  static const String perfekt = 'hat entschlossen';
  static const String arabicTranslation = 'استخلاص / كشف الإبرام (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2523_entschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entschliessen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الإبرام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
