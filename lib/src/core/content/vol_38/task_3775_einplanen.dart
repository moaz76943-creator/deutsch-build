// Sovereign Polyglot Core - Task 3775 (Financial Auditing)
class Task3775Engine {
  static const int taskId = 3775;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'einplanen';
  static const String praeteritum = 'plante ein';
  static const String perfekt = 'hat eingeplant';
  static const String arabicTranslation = 'إدراج / دمج التخطيط (التدقيق المالي)';
  static const String ipaTranscription = '[einˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3775_einplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung einplanen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التخطيط في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
