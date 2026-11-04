// Sovereign Polyglot Core - Task 4097 (Financial Auditing)
class Task4097Engine {
  static const int taskId = 4097;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'nachteilen';
  static const String praeteritum = 'teilte nach';
  static const String perfekt = 'hat nachgeteilt';
  static const String arabicTranslation = 'تدقيق / متابعة التقسيم (التدقيق المالي)';
  static const String ipaTranscription = '[nachˈˈtaɪ̯lən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4097_nachteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung nachteilen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التقسيم في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
