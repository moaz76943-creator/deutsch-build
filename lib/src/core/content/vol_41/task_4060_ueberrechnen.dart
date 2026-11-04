// Sovereign Polyglot Core - Task 4060 (Financial Auditing)
class Task4060Engine {
  static const int taskId = 4060;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'ueberrechnen';
  static const String praeteritum = 'ueberrechnete';
  static const String perfekt = 'hat ueberrechnet';
  static const String arabicTranslation = 'مراجعة / نقل التقدير (التدقيق المالي)';
  static const String ipaTranscription = '[ueberˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4060_ueberrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung ueberrechnen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التقدير في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
