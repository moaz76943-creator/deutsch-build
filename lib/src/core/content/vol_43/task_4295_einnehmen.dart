// Sovereign Polyglot Core - Task 4295 (Supply Chain)
class Task4295Engine {
  static const int taskId = 4295;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'einnehmen';
  static const String praeteritum = 'nahm ein';
  static const String perfekt = 'hat eingenommen';
  static const String arabicTranslation = 'إدراج / دمج الاستلام (سلاسل الإمداد)';
  static const String ipaTranscription = '[einˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4295_einnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale einnehmen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الاستلام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
