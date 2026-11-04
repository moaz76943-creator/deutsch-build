// Sovereign Polyglot Core - Task 4102 (Financial Auditing)
class Task4102Engine {
  static const int taskId = 4102;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'verteilen';
  static const String praeteritum = 'verteilte';
  static const String perfekt = 'hat verteilt';
  static const String arabicTranslation = 'توثيق / معالجة التقسيم (التدقيق المالي)';
  static const String ipaTranscription = '[verˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4102_verteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung verteilen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التقسيم في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
