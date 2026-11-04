// Sovereign Polyglot Core - Task 4077 (Financial Auditing)
class Task4077Engine {
  static const int taskId = 4077;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'nachordnen';
  static const String praeteritum = 'ordnete nach';
  static const String perfekt = 'hat nachgeordnet';
  static const String arabicTranslation = 'تدقيق / متابعة التصنيف (التدقيق المالي)';
  static const String ipaTranscription = '[nachˈˈɔʁdnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4077_nachordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung nachordnen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التصنيف في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
