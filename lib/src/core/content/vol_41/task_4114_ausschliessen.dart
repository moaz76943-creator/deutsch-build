// Sovereign Polyglot Core - Task 4114 (Financial Auditing)
class Task4114Engine {
  static const int taskId = 4114;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'ausschliessen';
  static const String praeteritum = 'schloss aus';
  static const String perfekt = 'hat ausgeschlossen';
  static const String arabicTranslation = 'توسيع / استخراج الإبرام (التدقيق المالي)';
  static const String ipaTranscription = '[ausˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4114_ausschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung ausschliessen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج الإبرام في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
