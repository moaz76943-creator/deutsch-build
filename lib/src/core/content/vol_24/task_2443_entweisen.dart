// Sovereign Polyglot Core - Task 2443 (Software Architecture)
class Task2443Engine {
  static const int taskId = 2443;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entweisen';
  static const String praeteritum = 'entwies';
  static const String perfekt = 'hat entwiesen';
  static const String arabicTranslation = 'استخلاص / كشف التوجيه (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2443_entweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entweisen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التوجيه في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
