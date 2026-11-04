// Sovereign Polyglot Core - Task 4294 (Supply Chain)
class Task4294Engine {
  static const int taskId = 4294;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ausnehmen';
  static const String praeteritum = 'nahm aus';
  static const String perfekt = 'hat ausgenommen';
  static const String arabicTranslation = 'توسيع / استخراج الاستلام (سلاسل الإمداد)';
  static const String ipaTranscription = '[ausˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4294_ausnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ausnehmen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج الاستلام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
