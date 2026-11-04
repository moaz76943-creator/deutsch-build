// Sovereign Polyglot Core - Task 4419 (Supply Chain)
class Task4419Engine {
  static const int taskId = 4419;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'zutragen';
  static const String praeteritum = 'trug zu';
  static const String perfekt = 'hat zugetragen';
  static const String arabicTranslation = 'توجيه / إغلاق المسؤولية (سلاسل الإمداد)';
  static const String ipaTranscription = '[zuˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4419_zutragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale zutragen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق المسؤولية في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
