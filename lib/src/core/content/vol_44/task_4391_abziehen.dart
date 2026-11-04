// Sovereign Polyglot Core - Task 4391 (Supply Chain)
class Task4391Engine {
  static const int taskId = 4391;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'abziehen';
  static const String praeteritum = 'zog ab';
  static const String perfekt = 'hat abgezogen';
  static const String arabicTranslation = 'فصل / إتمام الاستنتاج (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4391_abziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale abziehen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الاستنتاج في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
