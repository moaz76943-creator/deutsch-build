// Sovereign Polyglot Core - Task 3477 (Contractual Compliance)
class Task3477Engine {
  static const int taskId = 3477;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'nachsetzen';
  static const String praeteritum = 'setzte nach';
  static const String perfekt = 'hat nachgesetzt';
  static const String arabicTranslation = 'تدقيق / متابعة التنفيذ (العقود والإدارة)';
  static const String ipaTranscription = '[nachˈˈzɛtsn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3477_nachsetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung nachsetzen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التنفيذ أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
