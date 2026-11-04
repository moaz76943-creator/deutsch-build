// Sovereign Polyglot Core - Task 4140 (Financial Auditing)
class Task4140Engine {
  static const int taskId = 4140;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'ueberbauen';
  static const String praeteritum = 'ueberbaute';
  static const String perfekt = 'hat ueberbaut';
  static const String arabicTranslation = 'مراجعة / نقل التطوير (التدقيق المالي)';
  static const String ipaTranscription = '[ueberˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4140_ueberbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung ueberbauen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التطوير في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
