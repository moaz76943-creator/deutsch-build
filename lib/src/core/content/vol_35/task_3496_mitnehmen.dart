// Sovereign Polyglot Core - Task 3496 (Contractual Compliance)
class Task3496Engine {
  static const int taskId = 3496;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'mitnehmen';
  static const String praeteritum = 'nahm mit';
  static const String perfekt = 'hat mitgenommen';
  static const String arabicTranslation = 'مشاركة / تنسيق الاستلام (العقود والإدارة)';
  static const String ipaTranscription = '[mitˈˈneːmən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3496_mitnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung mitnehmen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق الاستلام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
