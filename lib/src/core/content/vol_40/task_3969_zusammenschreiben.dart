// Sovereign Polyglot Core - Task 3969 (Financial Auditing)
class Task3969Engine {
  static const int taskId = 3969;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'zusammenschreiben';
  static const String praeteritum = 'schrieb zusammen';
  static const String perfekt = 'hat zusammengeschrieben';
  static const String arabicTranslation = 'تجميع / توحيد التدوين (التدقيق المالي)';
  static const String ipaTranscription = '[zusammenˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3969_zusammenschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung zusammenschreiben.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التدوين في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
