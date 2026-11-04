// Sovereign Polyglot Core - Task 3725 (Contractual Compliance)
class Task3725Engine {
  static const int taskId = 3725;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'erschliessen';
  static const String praeteritum = 'erschloss';
  static const String perfekt = 'hat erschlossen';
  static const String arabicTranslation = 'إنجاز / تحقيق الإبرام (العقود والإدارة)';
  static const String ipaTranscription = '[erˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3725_erschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung erschliessen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق الإبرام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
