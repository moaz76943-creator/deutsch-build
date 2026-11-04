// Sovereign Polyglot Core - Task 3704 (Contractual Compliance)
class Task3704Engine {
  static const int taskId = 3704;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'beteilen';
  static const String praeteritum = 'beteilte';
  static const String perfekt = 'hat beteilt';
  static const String arabicTranslation = 'تأكيد / تزويد التقسيم (العقود والإدارة)';
  static const String ipaTranscription = '[beˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3704_beteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung beteilen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التقسيم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
