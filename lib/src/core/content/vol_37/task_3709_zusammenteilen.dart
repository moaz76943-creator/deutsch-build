// Sovereign Polyglot Core - Task 3709 (Contractual Compliance)
class Task3709Engine {
  static const int taskId = 3709;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'zusammenteilen';
  static const String praeteritum = 'teilte zusammen';
  static const String perfekt = 'hat zusammengeteilt';
  static const String arabicTranslation = 'تجميع / توحيد التقسيم (العقود والإدارة)';
  static const String ipaTranscription = '[zusammenˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3709_zusammenteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung zusammenteilen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التقسيم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
