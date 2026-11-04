// Sovereign Polyglot Core - Task 4080 (Financial Auditing)
class Task4080Engine {
  static const int taskId = 4080;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'ueberordnen';
  static const String praeteritum = 'ueberordnete';
  static const String perfekt = 'hat ueberordnet';
  static const String arabicTranslation = 'مراجعة / نقل التصنيف (التدقيق المالي)';
  static const String ipaTranscription = '[ueberˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4080_ueberordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung ueberordnen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التصنيف في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
