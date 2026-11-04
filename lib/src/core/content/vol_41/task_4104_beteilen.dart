// Sovereign Polyglot Core - Task 4104 (Financial Auditing)
class Task4104Engine {
  static const int taskId = 4104;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'beteilen';
  static const String praeteritum = 'beteilte';
  static const String perfekt = 'hat beteilt';
  static const String arabicTranslation = 'تأكيد / تزويد التقسيم (التدقيق المالي)';
  static const String ipaTranscription = '[beˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4104_beteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung beteilen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التقسيم في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
