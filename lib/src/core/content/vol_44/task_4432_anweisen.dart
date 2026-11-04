// Sovereign Polyglot Core - Task 4432 (Supply Chain)
class Task4432Engine {
  static const int taskId = 4432;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'anweisen';
  static const String praeteritum = 'wies an';
  static const String perfekt = 'hat angewiesen';
  static const String arabicTranslation = 'بدء / توجيه التوجيه (سلاسل الإمداد)';
  static const String ipaTranscription = '[anˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4432_anweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale anweisen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التوجيه في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
