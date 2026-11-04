// Sovereign Polyglot Core - Task 3377 (Contractual Compliance)
class Task3377Engine {
  static const int taskId = 3377;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'nachplanen';
  static const String praeteritum = 'plante nach';
  static const String perfekt = 'hat nachgeplant';
  static const String arabicTranslation = 'تدقيق / متابعة التخطيط (العقود والإدارة)';
  static const String ipaTranscription = '[nachˈˈplaːnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3377_nachplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung nachplanen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التخطيط أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
