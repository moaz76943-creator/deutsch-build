// Sovereign Polyglot Core - Task 3656 (Contractual Compliance)
class Task3656Engine {
  static const int taskId = 3656;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'mitrechnen';
  static const String praeteritum = 'rechnete mit';
  static const String perfekt = 'hat mitgerechnet';
  static const String arabicTranslation = 'مشاركة / تنسيق التقدير (العقود والإدارة)';
  static const String ipaTranscription = '[mitˈˈʁɛçnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3656_mitrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung mitrechnen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التقدير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
