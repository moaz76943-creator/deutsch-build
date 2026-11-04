// Sovereign Polyglot Core - Task 4394 (Supply Chain)
class Task4394Engine {
  static const int taskId = 4394;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ausziehen';
  static const String praeteritum = 'zog aus';
  static const String perfekt = 'hat ausgezogen';
  static const String arabicTranslation = 'توسيع / استخراج الاستنتاج (سلاسل الإمداد)';
  static const String ipaTranscription = '[ausˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4394_ausziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ausziehen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج الاستنتاج في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
