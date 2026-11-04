// Sovereign Polyglot Core - Task 3538 (Contractual Compliance)
class Task3538Engine {
  static const int taskId = 3538;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'vorhalten';
  static const String praeteritum = 'hielt vor';
  static const String perfekt = 'hat vorgehalten';
  static const String arabicTranslation = 'تقديم / تحضير الالتزام (العقود والإدارة)';
  static const String ipaTranscription = '[vorˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3538_vorhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung vorhalten.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير الالتزام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
