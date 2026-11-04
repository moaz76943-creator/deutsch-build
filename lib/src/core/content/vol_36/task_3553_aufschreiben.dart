// Sovereign Polyglot Core - Task 3553 (Contractual Compliance)
class Task3553Engine {
  static const int taskId = 3553;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'aufschreiben';
  static const String praeteritum = 'schrieb auf';
  static const String perfekt = 'hat aufgeschrieben';
  static const String arabicTranslation = 'رفع / فتح التدوين (العقود والإدارة)';
  static const String ipaTranscription = '[aufˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3553_aufschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung aufschreiben.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التدوين أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
