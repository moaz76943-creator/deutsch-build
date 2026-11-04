// Sovereign Polyglot Core - Task 4408 (Supply Chain)
class Task4408Engine {
  static const int taskId = 4408;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'weiterziehen';
  static const String praeteritum = 'zog weiter';
  static const String perfekt = 'hat weitergezogen';
  static const String arabicTranslation = 'مواصلة / تمرير الاستنتاج (سلاسل الإمداد)';
  static const String ipaTranscription = '[weiterˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4408_weiterziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale weiterziehen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير الاستنتاج في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
