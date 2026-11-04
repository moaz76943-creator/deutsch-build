// Sovereign Polyglot Core - Task 4129 (Financial Auditing)
class Task4129Engine {
  static const int taskId = 4129;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'zusammenschliessen';
  static const String praeteritum = 'schloss zusammen';
  static const String perfekt = 'hat zusammengeschlossen';
  static const String arabicTranslation = 'تجميع / توحيد الإبرام (التدقيق المالي)';
  static const String ipaTranscription = '[zusammenˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4129_zusammenschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung zusammenschliessen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد الإبرام في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
