// Sovereign Polyglot Core - Task 3964 (Financial Auditing)
class Task3964Engine {
  static const int taskId = 3964;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'beschreiben';
  static const String praeteritum = 'beschrieb';
  static const String perfekt = 'hat beschrieben';
  static const String arabicTranslation = 'تأكيد / تزويد التدوين (التدقيق المالي)';
  static const String ipaTranscription = '[beˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3964_beschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung beschreiben.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التدوين في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
