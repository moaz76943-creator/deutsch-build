// Sovereign Polyglot Core - Task 3715 (Contractual Compliance)
class Task3715Engine {
  static const int taskId = 3715;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'einschliessen';
  static const String praeteritum = 'schloss ein';
  static const String perfekt = 'hat eingeschlossen';
  static const String arabicTranslation = 'إدراج / دمج الإبرام (العقود والإدارة)';
  static const String ipaTranscription = '[einˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3715_einschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung einschliessen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الإبرام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
