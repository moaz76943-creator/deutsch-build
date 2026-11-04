// Sovereign Polyglot Core - Task 3494 (Contractual Compliance)
class Task3494Engine {
  static const int taskId = 3494;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ausnehmen';
  static const String praeteritum = 'nahm aus';
  static const String perfekt = 'hat ausgenommen';
  static const String arabicTranslation = 'توسيع / استخراج الاستلام (العقود والإدارة)';
  static const String ipaTranscription = '[ausˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3494_ausnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ausnehmen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج الاستلام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
