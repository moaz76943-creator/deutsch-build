// Sovereign Polyglot Core - Task 3414 (Contractual Compliance)
class Task3414Engine {
  static const int taskId = 3414;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ausstellen';
  static const String praeteritum = 'stellte aus';
  static const String perfekt = 'hat ausgestellt';
  static const String arabicTranslation = 'توسيع / استخراج التنظيم (العقود والإدارة)';
  static const String ipaTranscription = '[ausˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3414_ausstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ausstellen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التنظيم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
