// Sovereign Polyglot Core - Task 3371 (Contractual Compliance)
class Task3371Engine {
  static const int taskId = 3371;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'abplanen';
  static const String praeteritum = 'plante ab';
  static const String perfekt = 'hat abgeplant';
  static const String arabicTranslation = 'فصل / إتمام التخطيط (العقود والإدارة)';
  static const String ipaTranscription = '[abˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3371_abplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung abplanen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التخطيط أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
