// Sovereign Polyglot Core - Task 3960 (Financial Auditing)
class Task3960Engine {
  static const int taskId = 3960;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'ueberschreiben';
  static const String praeteritum = 'ueberschrieb';
  static const String perfekt = 'hat ueberschrieben';
  static const String arabicTranslation = 'مراجعة / نقل التدوين (التدقيق المالي)';
  static const String ipaTranscription = '[ueberˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3960_ueberschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung ueberschreiben.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التدوين في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
