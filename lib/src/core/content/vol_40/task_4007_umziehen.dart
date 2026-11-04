// Sovereign Polyglot Core - Task 4007 (Financial Auditing)
class Task4007Engine {
  static const int taskId = 4007;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'umziehen';
  static const String praeteritum = 'zog um';
  static const String perfekt = 'hat umgezogen';
  static const String arabicTranslation = 'إعادة هيكلة الاستنتاج (التدقيق المالي)';
  static const String ipaTranscription = '[umˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4007_umziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung umziehen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة الاستنتاج في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
