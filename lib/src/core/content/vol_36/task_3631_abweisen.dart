// Sovereign Polyglot Core - Task 3631 (Contractual Compliance)
class Task3631Engine {
  static const int taskId = 3631;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'abweisen';
  static const String praeteritum = 'wies ab';
  static const String perfekt = 'hat abgewiesen';
  static const String arabicTranslation = 'فصل / إتمام التوجيه (العقود والإدارة)';
  static const String ipaTranscription = '[abˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3631_abweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung abweisen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التوجيه أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
