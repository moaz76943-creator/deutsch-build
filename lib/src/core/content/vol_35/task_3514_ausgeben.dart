// Sovereign Polyglot Core - Task 3514 (Contractual Compliance)
class Task3514Engine {
  static const int taskId = 3514;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ausgeben';
  static const String praeteritum = 'gab aus';
  static const String perfekt = 'hat ausgegeben';
  static const String arabicTranslation = 'توسيع / استخراج التسليم (العقود والإدارة)';
  static const String ipaTranscription = '[ausˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3514_ausgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ausgeben.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التسليم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
