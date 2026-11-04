// Sovereign Polyglot Core - Task 3471 (Contractual Compliance)
class Task3471Engine {
  static const int taskId = 3471;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'absetzen';
  static const String praeteritum = 'setzte ab';
  static const String perfekt = 'hat abgesetzt';
  static const String arabicTranslation = 'فصل / إتمام التنفيذ (العقود والإدارة)';
  static const String ipaTranscription = '[abˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3471_absetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung absetzen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التنفيذ أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
