// Sovereign Polyglot Core - Task 3991 (Financial Auditing)
class Task3991Engine {
  static const int taskId = 3991;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'abziehen';
  static const String praeteritum = 'zog ab';
  static const String perfekt = 'hat abgezogen';
  static const String arabicTranslation = 'فصل / إتمام الاستنتاج (التدقيق المالي)';
  static const String ipaTranscription = '[abˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3991_abziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung abziehen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الاستنتاج في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
