// Sovereign Polyglot Core - Task 2354 (Software Architecture)
class Task2354Engine {
  static const int taskId = 2354;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ausschreiben';
  static const String praeteritum = 'schrieb aus';
  static const String perfekt = 'hat ausgeschrieben';
  static const String arabicTranslation = 'توسيع / استخراج التدوين (هندسة البرمجيات)';
  static const String ipaTranscription = '[ausˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2354_ausschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ausschreiben.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التدوين في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
