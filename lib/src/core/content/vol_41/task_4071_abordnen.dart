// Sovereign Polyglot Core - Task 4071 (Financial Auditing)
class Task4071Engine {
  static const int taskId = 4071;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'abordnen';
  static const String praeteritum = 'ordnete ab';
  static const String perfekt = 'hat abgeordnet';
  static const String arabicTranslation = 'فصل / إتمام التصنيف (التدقيق المالي)';
  static const String ipaTranscription = '[abˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4071_abordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung abordnen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التصنيف في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
