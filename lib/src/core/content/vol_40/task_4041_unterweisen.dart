// Sovereign Polyglot Core - Task 4041 (Financial Auditing)
class Task4041Engine {
  static const int taskId = 4041;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'unterweisen';
  static const String praeteritum = 'unterwies';
  static const String perfekt = 'hat unterwiesen';
  static const String arabicTranslation = 'فحص / دعم التوجيه (التدقيق المالي)';
  static const String ipaTranscription = '[unterˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4041_unterweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung unterweisen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التوجيه في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
