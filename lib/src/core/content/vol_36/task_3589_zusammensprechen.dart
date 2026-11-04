// Sovereign Polyglot Core - Task 3589 (Contractual Compliance)
class Task3589Engine {
  static const int taskId = 3589;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'zusammensprechen';
  static const String praeteritum = 'sprach zusammen';
  static const String perfekt = 'hat zusammengesprochen';
  static const String arabicTranslation = 'تجميع / توحيد التخاطب (العقود والإدارة)';
  static const String ipaTranscription = '[zusammenˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3589_zusammensprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung zusammensprechen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التخاطب أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
