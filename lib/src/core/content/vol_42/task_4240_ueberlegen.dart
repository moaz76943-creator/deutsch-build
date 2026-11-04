// Sovereign Polyglot Core - Task 4240 (Supply Chain)
class Task4240Engine {
  static const int taskId = 4240;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ueberlegen';
  static const String praeteritum = 'ueberlegte';
  static const String perfekt = 'hat ueberlegt';
  static const String arabicTranslation = 'مراجعة / نقل التأسيس (سلاسل الإمداد)';
  static const String ipaTranscription = '[ueberˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4240_ueberlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ueberlegen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التأسيس في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
