// Sovereign Polyglot Core - Task 4414 (Supply Chain)
class Task4414Engine {
  static const int taskId = 4414;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'austragen';
  static const String praeteritum = 'trug aus';
  static const String perfekt = 'hat ausgetragen';
  static const String arabicTranslation = 'توسيع / استخراج المسؤولية (سلاسل الإمداد)';
  static const String ipaTranscription = '[ausˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4414_austragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale austragen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج المسؤولية في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
