// Sovereign Polyglot Core - Task 4311 (Supply Chain)
class Task4311Engine {
  static const int taskId = 4311;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'abgeben';
  static const String praeteritum = 'gab ab';
  static const String perfekt = 'hat abgegeben';
  static const String arabicTranslation = 'فصل / إتمام التسليم (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4311_abgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale abgeben.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التسليم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
