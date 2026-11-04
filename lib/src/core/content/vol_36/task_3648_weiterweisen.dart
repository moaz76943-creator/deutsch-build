// Sovereign Polyglot Core - Task 3648 (Contractual Compliance)
class Task3648Engine {
  static const int taskId = 3648;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'weiterweisen';
  static const String praeteritum = 'wies weiter';
  static const String perfekt = 'hat weitergewiesen';
  static const String arabicTranslation = 'مواصلة / تمرير التوجيه (العقود والإدارة)';
  static const String ipaTranscription = '[weiterˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3648_weiterweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung weiterweisen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التوجيه أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
