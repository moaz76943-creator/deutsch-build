// Sovereign Polyglot Core - Task 3697 (Contractual Compliance)
class Task3697Engine {
  static const int taskId = 3697;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'nachteilen';
  static const String praeteritum = 'teilte nach';
  static const String perfekt = 'hat nachgeteilt';
  static const String arabicTranslation = 'تدقيق / متابعة التقسيم (العقود والإدارة)';
  static const String ipaTranscription = '[nachˈˈtaɪ̯lən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3697_nachteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung nachteilen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التقسيم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
