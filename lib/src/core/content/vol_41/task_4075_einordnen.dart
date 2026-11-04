// Sovereign Polyglot Core - Task 4075 (Financial Auditing)
class Task4075Engine {
  static const int taskId = 4075;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'einordnen';
  static const String praeteritum = 'ordnete ein';
  static const String perfekt = 'hat eingeordnet';
  static const String arabicTranslation = 'إدراج / دمج التصنيف (التدقيق المالي)';
  static const String ipaTranscription = '[einˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4075_einordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung einordnen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التصنيف في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
