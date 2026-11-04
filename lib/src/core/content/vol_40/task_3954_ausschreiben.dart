// Sovereign Polyglot Core - Task 3954 (Financial Auditing)
class Task3954Engine {
  static const int taskId = 3954;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'ausschreiben';
  static const String praeteritum = 'schrieb aus';
  static const String perfekt = 'hat ausgeschrieben';
  static const String arabicTranslation = 'توسيع / استخراج التدوين (التدقيق المالي)';
  static const String ipaTranscription = '[ausˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3954_ausschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung ausschreiben.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التدوين في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
