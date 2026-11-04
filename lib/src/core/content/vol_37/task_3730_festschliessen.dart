// Sovereign Polyglot Core - Task 3730 (Contractual Compliance)
class Task3730Engine {
  static const int taskId = 3730;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'festschliessen';
  static const String praeteritum = 'schloss fest';
  static const String perfekt = 'hat festgeschlossen';
  static const String arabicTranslation = 'تثبيت / إقرار الإبرام (العقود والإدارة)';
  static const String ipaTranscription = '[festˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3730_festschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung festschliessen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار الإبرام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
