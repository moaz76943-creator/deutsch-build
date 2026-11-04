// Sovereign Polyglot Core - Task 3696 (Contractual Compliance)
class Task3696Engine {
  static const int taskId = 3696;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'mitteilen';
  static const String praeteritum = 'teilte mit';
  static const String perfekt = 'hat mitgeteilt';
  static const String arabicTranslation = 'مشاركة / تنسيق التقسيم (العقود والإدارة)';
  static const String ipaTranscription = '[mitˈˈtaɪ̯lən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3696_mitteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung mitteilen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التقسيم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
