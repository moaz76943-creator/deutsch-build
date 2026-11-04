// Sovereign Polyglot Core - Task 3676 (Contractual Compliance)
class Task3676Engine {
  static const int taskId = 3676;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'mitordnen';
  static const String praeteritum = 'ordnete mit';
  static const String perfekt = 'hat mitgeordnet';
  static const String arabicTranslation = 'مشاركة / تنسيق التصنيف (العقود والإدارة)';
  static const String ipaTranscription = '[mitˈˈɔʁdnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3676_mitordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung mitordnen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التصنيف أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
