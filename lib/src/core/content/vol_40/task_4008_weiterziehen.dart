// Sovereign Polyglot Core - Task 4008 (Financial Auditing)
class Task4008Engine {
  static const int taskId = 4008;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'weiterziehen';
  static const String praeteritum = 'zog weiter';
  static const String perfekt = 'hat weitergezogen';
  static const String arabicTranslation = 'مواصلة / تمرير الاستنتاج (التدقيق المالي)';
  static const String ipaTranscription = '[weiterˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4008_weiterziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung weiterziehen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير الاستنتاج في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
