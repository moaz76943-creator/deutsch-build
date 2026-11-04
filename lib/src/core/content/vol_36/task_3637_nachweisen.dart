// Sovereign Polyglot Core - Task 3637 (Contractual Compliance)
class Task3637Engine {
  static const int taskId = 3637;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'nachweisen';
  static const String praeteritum = 'wies nach';
  static const String perfekt = 'hat nachgewiesen';
  static const String arabicTranslation = 'تدقيق / متابعة التوجيه (العقود والإدارة)';
  static const String ipaTranscription = '[nachˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3637_nachweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung nachweisen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التوجيه أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
