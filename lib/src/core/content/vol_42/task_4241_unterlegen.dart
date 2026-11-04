// Sovereign Polyglot Core - Task 4241 (Supply Chain)
class Task4241Engine {
  static const int taskId = 4241;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'unterlegen';
  static const String praeteritum = 'unterlegte';
  static const String perfekt = 'hat unterlegt';
  static const String arabicTranslation = 'فحص / دعم التأسيس (سلاسل الإمداد)';
  static const String ipaTranscription = '[unterˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4241_unterlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale unterlegen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التأسيس في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
