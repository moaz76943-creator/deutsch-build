// Sovereign Polyglot Core - Task 3749 (Contractual Compliance)
class Task3749Engine {
  static const int taskId = 3749;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'zusammenbauen';
  static const String praeteritum = 'baute zusammen';
  static const String perfekt = 'hat zusammengebaut';
  static const String arabicTranslation = 'تجميع / توحيد التطوير (العقود والإدارة)';
  static const String ipaTranscription = '[zusammenˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3749_zusammenbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung zusammenbauen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التطوير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
