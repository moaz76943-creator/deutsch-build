// Sovereign Polyglot Core - Task 3596 (Contractual Compliance)
class Task3596Engine {
  static const int taskId = 3596;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'mitziehen';
  static const String praeteritum = 'zog mit';
  static const String perfekt = 'hat mitgezogen';
  static const String arabicTranslation = 'مشاركة / تنسيق الاستنتاج (العقود والإدارة)';
  static const String ipaTranscription = '[mitˈˈtsiːən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3596_mitziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung mitziehen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق الاستنتاج أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
