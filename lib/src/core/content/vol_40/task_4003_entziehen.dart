// Sovereign Polyglot Core - Task 4003 (Financial Auditing)
class Task4003Engine {
  static const int taskId = 4003;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'entziehen';
  static const String praeteritum = 'entzog';
  static const String perfekt = 'hat entzogen';
  static const String arabicTranslation = 'استخلاص / كشف الاستنتاج (التدقيق المالي)';
  static const String ipaTranscription = '[entˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4003_entziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung entziehen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الاستنتاج في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
