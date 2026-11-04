// Sovereign Polyglot Core - Task 4314 (Supply Chain)
class Task4314Engine {
  static const int taskId = 4314;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ausgeben';
  static const String praeteritum = 'gab aus';
  static const String perfekt = 'hat ausgegeben';
  static const String arabicTranslation = 'توسيع / استخراج التسليم (سلاسل الإمداد)';
  static const String ipaTranscription = '[ausˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4314_ausgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ausgeben.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التسليم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
