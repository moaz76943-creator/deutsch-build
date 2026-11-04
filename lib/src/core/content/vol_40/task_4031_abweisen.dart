// Sovereign Polyglot Core - Task 4031 (Financial Auditing)
class Task4031Engine {
  static const int taskId = 4031;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'abweisen';
  static const String praeteritum = 'wies ab';
  static const String perfekt = 'hat abgewiesen';
  static const String arabicTranslation = 'فصل / إتمام التوجيه (التدقيق المالي)';
  static const String ipaTranscription = '[abˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4031_abweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung abweisen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التوجيه في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
