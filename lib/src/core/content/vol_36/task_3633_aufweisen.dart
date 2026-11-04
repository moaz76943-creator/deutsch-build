// Sovereign Polyglot Core - Task 3633 (Contractual Compliance)
class Task3633Engine {
  static const int taskId = 3633;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'aufweisen';
  static const String praeteritum = 'wies auf';
  static const String perfekt = 'hat aufgewiesen';
  static const String arabicTranslation = 'رفع / فتح التوجيه (العقود والإدارة)';
  static const String ipaTranscription = '[aufˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3633_aufweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung aufweisen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التوجيه أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
