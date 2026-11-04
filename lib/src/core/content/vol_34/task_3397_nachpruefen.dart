// Sovereign Polyglot Core - Task 3397 (Contractual Compliance)
class Task3397Engine {
  static const int taskId = 3397;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'nachpruefen';
  static const String praeteritum = 'pruefte nach';
  static const String perfekt = 'hat nachgeprueft';
  static const String arabicTranslation = 'تدقيق / متابعة التدقيق (العقود والإدارة)';
  static const String ipaTranscription = '[nachˈˈpʁyːfn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3397_nachpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung nachpruefen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التدقيق أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
