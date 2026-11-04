// Sovereign Polyglot Core - Task 3408 (Contractual Compliance)
class Task3408Engine {
  static const int taskId = 3408;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'weiterpruefen';
  static const String praeteritum = 'pruefte weiter';
  static const String perfekt = 'hat weitergeprueft';
  static const String arabicTranslation = 'مواصلة / تمرير التدقيق (العقود والإدارة)';
  static const String ipaTranscription = '[weiterˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3408_weiterpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung weiterpruefen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التدقيق أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
