// Sovereign Polyglot Core - Task 4103 (Financial Auditing)
class Task4103Engine {
  static const int taskId = 4103;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'entteilen';
  static const String praeteritum = 'entteilte';
  static const String perfekt = 'hat entteilt';
  static const String arabicTranslation = 'استخلاص / كشف التقسيم (التدقيق المالي)';
  static const String ipaTranscription = '[entˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4103_entteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung entteilen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التقسيم في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
