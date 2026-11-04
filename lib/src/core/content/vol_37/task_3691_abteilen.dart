// Sovereign Polyglot Core - Task 3691 (Contractual Compliance)
class Task3691Engine {
  static const int taskId = 3691;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'abteilen';
  static const String praeteritum = 'teilte ab';
  static const String perfekt = 'hat abgeteilt';
  static const String arabicTranslation = 'فصل / إتمام التقسيم (العقود والإدارة)';
  static const String ipaTranscription = '[abˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3691_abteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung abteilen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التقسيم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
