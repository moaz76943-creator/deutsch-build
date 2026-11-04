// Sovereign Polyglot Core - Task 3537 (Contractual Compliance)
class Task3537Engine {
  static const int taskId = 3537;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'nachhalten';
  static const String praeteritum = 'hielt nach';
  static const String perfekt = 'hat nachgehalten';
  static const String arabicTranslation = 'تدقيق / متابعة الالتزام (العقود والإدارة)';
  static const String ipaTranscription = '[nachˈˈhaltn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3537_nachhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung nachhalten.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة الالتزام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
