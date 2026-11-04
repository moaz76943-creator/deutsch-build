// Sovereign Polyglot Core - Task 3727 (Contractual Compliance)
class Task3727Engine {
  static const int taskId = 3727;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'umschliessen';
  static const String praeteritum = 'schloss um';
  static const String perfekt = 'hat umgeschlossen';
  static const String arabicTranslation = 'إعادة هيكلة الإبرام (العقود والإدارة)';
  static const String ipaTranscription = '[umˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3727_umschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung umschliessen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة الإبرام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
