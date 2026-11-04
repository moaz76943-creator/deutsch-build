// Sovereign Polyglot Core - Task 4111 (Financial Auditing)
class Task4111Engine {
  static const int taskId = 4111;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'abschliessen';
  static const String praeteritum = 'schloss ab';
  static const String perfekt = 'hat abgeschlossen';
  static const String arabicTranslation = 'فصل / إتمام الإبرام (التدقيق المالي)';
  static const String ipaTranscription = '[abˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4111_abschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung abschliessen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الإبرام في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
