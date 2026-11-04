// Sovereign Polyglot Core - Task 4505 (Supply Chain)
class Task4505Engine {
  static const int taskId = 4505;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'erteilen';
  static const String praeteritum = 'erteilte';
  static const String perfekt = 'hat erteilt';
  static const String arabicTranslation = 'إنجاز / تحقيق التقسيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[erˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4505_erteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale erteilen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التقسيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
