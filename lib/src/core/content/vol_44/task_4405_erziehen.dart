// Sovereign Polyglot Core - Task 4405 (Supply Chain)
class Task4405Engine {
  static const int taskId = 4405;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'erziehen';
  static const String praeteritum = 'erzog';
  static const String perfekt = 'hat erzogen';
  static const String arabicTranslation = 'إنجاز / تحقيق الاستنتاج (سلاسل الإمداد)';
  static const String ipaTranscription = '[erˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4405_erziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale erziehen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق الاستنتاج في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
