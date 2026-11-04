// Sovereign Polyglot Core - Task 3717 (Contractual Compliance)
class Task3717Engine {
  static const int taskId = 3717;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'nachschliessen';
  static const String praeteritum = 'schloss nach';
  static const String perfekt = 'hat nachgeschlossen';
  static const String arabicTranslation = 'تدقيق / متابعة الإبرام (العقود والإدارة)';
  static const String ipaTranscription = '[nachˈˈʃliːsn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3717_nachschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung nachschliessen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة الإبرام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
