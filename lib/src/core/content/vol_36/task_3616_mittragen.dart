// Sovereign Polyglot Core - Task 3616 (Contractual Compliance)
class Task3616Engine {
  static const int taskId = 3616;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'mittragen';
  static const String praeteritum = 'trug mit';
  static const String perfekt = 'hat mitgetragen';
  static const String arabicTranslation = 'مشاركة / تنسيق المسؤولية (العقود والإدارة)';
  static const String ipaTranscription = '[mitˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3616_mittragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung mittragen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق المسؤولية أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
