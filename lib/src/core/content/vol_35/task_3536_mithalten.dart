// Sovereign Polyglot Core - Task 3536 (Contractual Compliance)
class Task3536Engine {
  static const int taskId = 3536;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'mithalten';
  static const String praeteritum = 'hielt mit';
  static const String perfekt = 'hat mitgehalten';
  static const String arabicTranslation = 'مشاركة / تنسيق الالتزام (العقود والإدارة)';
  static const String ipaTranscription = '[mitˈˈhaltn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3536_mithalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung mithalten.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق الالتزام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
