// Sovereign Polyglot Core - Task 3774 (Financial Auditing)
class Task3774Engine {
  static const int taskId = 3774;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'ausplanen';
  static const String praeteritum = 'plante aus';
  static const String perfekt = 'hat ausgeplant';
  static const String arabicTranslation = 'توسيع / استخراج التخطيط (التدقيق المالي)';
  static const String ipaTranscription = '[ausˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3774_ausplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung ausplanen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التخطيط في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
