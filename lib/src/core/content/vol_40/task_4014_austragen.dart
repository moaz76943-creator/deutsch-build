// Sovereign Polyglot Core - Task 4014 (Financial Auditing)
class Task4014Engine {
  static const int taskId = 4014;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'austragen';
  static const String praeteritum = 'trug aus';
  static const String perfekt = 'hat ausgetragen';
  static const String arabicTranslation = 'توسيع / استخراج المسؤولية (التدقيق المالي)';
  static const String ipaTranscription = '[ausˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4014_austragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung austragen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج المسؤولية في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
