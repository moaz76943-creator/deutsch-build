// Sovereign Polyglot Core - Task 3897 (Financial Auditing)
class Task3897Engine {
  static const int taskId = 3897;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'nachnehmen';
  static const String praeteritum = 'nahm nach';
  static const String perfekt = 'hat nachgenommen';
  static const String arabicTranslation = 'تدقيق / متابعة الاستلام (التدقيق المالي)';
  static const String ipaTranscription = '[nachˈˈneːmən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3897_nachnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung nachnehmen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة الاستلام في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
