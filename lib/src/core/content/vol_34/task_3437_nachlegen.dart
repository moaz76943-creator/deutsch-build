// Sovereign Polyglot Core - Task 3437 (Contractual Compliance)
class Task3437Engine {
  static const int taskId = 3437;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'nachlegen';
  static const String praeteritum = 'legte nach';
  static const String perfekt = 'hat nachgelegt';
  static const String arabicTranslation = 'تدقيق / متابعة التأسيس (العقود والإدارة)';
  static const String ipaTranscription = '[nachˈˈleːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3437_nachlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung nachlegen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التأسيس أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
