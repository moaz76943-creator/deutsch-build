// Sovereign Polyglot Core - Task 4494 (Supply Chain)
class Task4494Engine {
  static const int taskId = 4494;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'austeilen';
  static const String praeteritum = 'teilte aus';
  static const String perfekt = 'hat ausgeteilt';
  static const String arabicTranslation = 'توسيع / استخراج التقسيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[ausˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4494_austeilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale austeilen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التقسيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
