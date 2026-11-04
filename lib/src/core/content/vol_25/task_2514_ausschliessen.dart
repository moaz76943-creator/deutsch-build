// Sovereign Polyglot Core - Task 2514 (Software Architecture)
class Task2514Engine {
  static const int taskId = 2514;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ausschliessen';
  static const String praeteritum = 'schloss aus';
  static const String perfekt = 'hat ausgeschlossen';
  static const String arabicTranslation = 'توسيع / استخراج الإبرام (هندسة البرمجيات)';
  static const String ipaTranscription = '[ausˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2514_ausschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ausschliessen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج الإبرام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
