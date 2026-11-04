// Sovereign Polyglot Core - Task 3376 (Contractual Compliance)
class Task3376Engine {
  static const int taskId = 3376;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'mitplanen';
  static const String praeteritum = 'plante mit';
  static const String perfekt = 'hat mitgeplant';
  static const String arabicTranslation = 'مشاركة / تنسيق التخطيط (العقود والإدارة)';
  static const String ipaTranscription = '[mitˈˈplaːnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3376_mitplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung mitplanen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التخطيط أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
