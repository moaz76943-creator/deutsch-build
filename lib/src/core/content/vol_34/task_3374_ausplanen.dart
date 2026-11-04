// Sovereign Polyglot Core - Task 3374 (Contractual Compliance)
class Task3374Engine {
  static const int taskId = 3374;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ausplanen';
  static const String praeteritum = 'plante aus';
  static const String perfekt = 'hat ausgeplant';
  static const String arabicTranslation = 'توسيع / استخراج التخطيط (العقود والإدارة)';
  static const String ipaTranscription = '[ausˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3374_ausplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ausplanen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التخطيط أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
