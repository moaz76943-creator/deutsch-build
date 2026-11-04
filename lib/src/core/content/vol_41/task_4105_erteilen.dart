// Sovereign Polyglot Core - Task 4105 (Financial Auditing)
class Task4105Engine {
  static const int taskId = 4105;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'erteilen';
  static const String praeteritum = 'erteilte';
  static const String perfekt = 'hat erteilt';
  static const String arabicTranslation = 'إنجاز / تحقيق التقسيم (التدقيق المالي)';
  static const String ipaTranscription = '[erˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4105_erteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung erteilen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التقسيم في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
