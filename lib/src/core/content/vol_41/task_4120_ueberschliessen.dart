// Sovereign Polyglot Core - Task 4120 (Financial Auditing)
class Task4120Engine {
  static const int taskId = 4120;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'ueberschliessen';
  static const String praeteritum = 'ueberschloss';
  static const String perfekt = 'hat ueberschlossen';
  static const String arabicTranslation = 'مراجعة / نقل الإبرام (التدقيق المالي)';
  static const String ipaTranscription = '[ueberˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4120_ueberschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung ueberschliessen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الإبرام في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
