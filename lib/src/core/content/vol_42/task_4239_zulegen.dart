// Sovereign Polyglot Core - Task 4239 (Supply Chain)
class Task4239Engine {
  static const int taskId = 4239;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'zulegen';
  static const String praeteritum = 'legte zu';
  static const String perfekt = 'hat zugelegt';
  static const String arabicTranslation = 'توجيه / إغلاق التأسيس (سلاسل الإمداد)';
  static const String ipaTranscription = '[zuˈˈleːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4239_zulegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale zulegen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التأسيس في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
