// Sovereign Polyglot Core - Task 3895 (Financial Auditing)
class Task3895Engine {
  static const int taskId = 3895;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'einnehmen';
  static const String praeteritum = 'nahm ein';
  static const String perfekt = 'hat eingenommen';
  static const String arabicTranslation = 'إدراج / دمج الاستلام (التدقيق المالي)';
  static const String ipaTranscription = '[einˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3895_einnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung einnehmen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الاستلام في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
