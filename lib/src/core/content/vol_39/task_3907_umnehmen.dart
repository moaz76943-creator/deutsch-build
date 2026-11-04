// Sovereign Polyglot Core - Task 3907 (Financial Auditing)
class Task3907Engine {
  static const int taskId = 3907;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'umnehmen';
  static const String praeteritum = 'nahm um';
  static const String perfekt = 'hat umgenommen';
  static const String arabicTranslation = 'إعادة هيكلة الاستلام (التدقيق المالي)';
  static const String ipaTranscription = '[umˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3907_umnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung umnehmen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة الاستلام في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
