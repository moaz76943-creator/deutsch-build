// Sovereign Polyglot Core - Task 3701 (Contractual Compliance)
class Task3701Engine {
  static const int taskId = 3701;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'unterteilen';
  static const String praeteritum = 'unterteilte';
  static const String perfekt = 'hat unterteilt';
  static const String arabicTranslation = 'فحص / دعم التقسيم (العقود والإدارة)';
  static const String ipaTranscription = '[unterˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3701_unterteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung unterteilen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التقسيم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
