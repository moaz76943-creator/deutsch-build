// Sovereign Polyglot Core - Task 3780 (Financial Auditing)
class Task3780Engine {
  static const int taskId = 3780;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'ueberplanen';
  static const String praeteritum = 'ueberplante';
  static const String perfekt = 'hat ueberplant';
  static const String arabicTranslation = 'مراجعة / نقل التخطيط (التدقيق المالي)';
  static const String ipaTranscription = '[ueberˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3780_ueberplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung ueberplanen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التخطيط في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
