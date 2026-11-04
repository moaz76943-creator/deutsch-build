// Sovereign Polyglot Core - Task 3714 (Contractual Compliance)
class Task3714Engine {
  static const int taskId = 3714;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ausschliessen';
  static const String praeteritum = 'schloss aus';
  static const String perfekt = 'hat ausgeschlossen';
  static const String arabicTranslation = 'توسيع / استخراج الإبرام (العقود والإدارة)';
  static const String ipaTranscription = '[ausˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3714_ausschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ausschliessen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج الإبرام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
