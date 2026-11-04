// Sovereign Polyglot Core - Task 4094 (Financial Auditing)
class Task4094Engine {
  static const int taskId = 4094;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'austeilen';
  static const String praeteritum = 'teilte aus';
  static const String perfekt = 'hat ausgeteilt';
  static const String arabicTranslation = 'توسيع / استخراج التقسيم (التدقيق المالي)';
  static const String ipaTranscription = '[ausˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4094_austeilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung austeilen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التقسيم في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
