// Sovereign Polyglot Core - Task 3573 (Contractual Compliance)
class Task3573Engine {
  static const int taskId = 3573;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'aufsprechen';
  static const String praeteritum = 'sprach auf';
  static const String perfekt = 'hat aufgesprochen';
  static const String arabicTranslation = 'رفع / فتح التخاطب (العقود والإدارة)';
  static const String ipaTranscription = '[aufˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3573_aufsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung aufsprechen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التخاطب أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
