// Sovereign Polyglot Core - Task 3581 (Contractual Compliance)
class Task3581Engine {
  static const int taskId = 3581;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'untersprechen';
  static const String praeteritum = 'untersprach';
  static const String perfekt = 'hat untersprochen';
  static const String arabicTranslation = 'فحص / دعم التخاطب (العقود والإدارة)';
  static const String ipaTranscription = '[unterˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3581_untersprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung untersprechen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التخاطب أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
