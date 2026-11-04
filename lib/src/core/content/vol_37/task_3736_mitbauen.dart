// Sovereign Polyglot Core - Task 3736 (Contractual Compliance)
class Task3736Engine {
  static const int taskId = 3736;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'mitbauen';
  static const String praeteritum = 'baute mit';
  static const String perfekt = 'hat mitgebaut';
  static const String arabicTranslation = 'مشاركة / تنسيق التطوير (العقود والإدارة)';
  static const String ipaTranscription = '[mitˈˈbaʊ̯ən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3736_mitbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung mitbauen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التطوير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
