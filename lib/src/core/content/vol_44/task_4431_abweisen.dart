// Sovereign Polyglot Core - Task 4431 (Supply Chain)
class Task4431Engine {
  static const int taskId = 4431;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'abweisen';
  static const String praeteritum = 'wies ab';
  static const String perfekt = 'hat abgewiesen';
  static const String arabicTranslation = 'فصل / إتمام التوجيه (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4431_abweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale abweisen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التوجيه في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
