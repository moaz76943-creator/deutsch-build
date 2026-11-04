// Sovereign Polyglot Core - Task 3811 (Financial Auditing)
class Task3811Engine {
  static const int taskId = 3811;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'abstellen';
  static const String praeteritum = 'stellte ab';
  static const String perfekt = 'hat abgestellt';
  static const String arabicTranslation = 'فصل / إتمام التنظيم (التدقيق المالي)';
  static const String ipaTranscription = '[abˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3811_abstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung abstellen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التنظيم في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
