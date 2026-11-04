// Sovereign Polyglot Core - Task 3393 (Contractual Compliance)
class Task3393Engine {
  static const int taskId = 3393;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'aufpruefen';
  static const String praeteritum = 'pruefte auf';
  static const String perfekt = 'hat aufgeprueft';
  static const String arabicTranslation = 'رفع / فتح التدقيق (العقود والإدارة)';
  static const String ipaTranscription = '[aufˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3393_aufpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung aufpruefen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التدقيق أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
