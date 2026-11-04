// Sovereign Polyglot Core - Task 3394 (Contractual Compliance)
class Task3394Engine {
  static const int taskId = 3394;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'auspruefen';
  static const String praeteritum = 'pruefte aus';
  static const String perfekt = 'hat ausgeprueft';
  static const String arabicTranslation = 'توسيع / استخراج التدقيق (العقود والإدارة)';
  static const String ipaTranscription = '[ausˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3394_auspruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung auspruefen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التدقيق أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
