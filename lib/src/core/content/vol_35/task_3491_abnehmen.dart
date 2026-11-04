// Sovereign Polyglot Core - Task 3491 (Contractual Compliance)
class Task3491Engine {
  static const int taskId = 3491;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'abnehmen';
  static const String praeteritum = 'nahm ab';
  static const String perfekt = 'hat abgenommen';
  static const String arabicTranslation = 'فصل / إتمام الاستلام (العقود والإدارة)';
  static const String ipaTranscription = '[abˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3491_abnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung abnehmen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الاستلام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
