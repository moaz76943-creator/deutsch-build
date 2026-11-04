// Sovereign Polyglot Core - Task 3731 (Contractual Compliance)
class Task3731Engine {
  static const int taskId = 3731;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'abbauen';
  static const String praeteritum = 'baute ab';
  static const String perfekt = 'hat abgebaut';
  static const String arabicTranslation = 'فصل / إتمام التطوير (العقود والإدارة)';
  static const String ipaTranscription = '[abˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3731_abbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung abbauen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التطوير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
