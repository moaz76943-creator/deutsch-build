// Sovereign Polyglot Core - Task 3389 (Contractual Compliance)
class Task3389Engine {
  static const int taskId = 3389;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'zusammenplanen';
  static const String praeteritum = 'plante zusammen';
  static const String perfekt = 'hat zusammengeplant';
  static const String arabicTranslation = 'تجميع / توحيد التخطيط (العقود والإدارة)';
  static const String ipaTranscription = '[zusammenˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3389_zusammenplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung zusammenplanen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التخطيط أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
