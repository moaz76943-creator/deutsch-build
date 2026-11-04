// Sovereign Polyglot Core - Task 3386 (Contractual Compliance)
class Task3386Engine {
  static const int taskId = 3386;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'durchplanen';
  static const String praeteritum = 'plante durch';
  static const String perfekt = 'hat durchgeplant';
  static const String arabicTranslation = 'إتمام شامل التخطيط (العقود والإدارة)';
  static const String ipaTranscription = '[durchˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3386_durchplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung durchplanen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التخطيط أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
