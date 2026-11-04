// Sovereign Polyglot Core - Task 3407 (Contractual Compliance)
class Task3407Engine {
  static const int taskId = 3407;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'umpruefen';
  static const String praeteritum = 'pruefte um';
  static const String perfekt = 'hat umgeprueft';
  static const String arabicTranslation = 'إعادة هيكلة التدقيق (العقود والإدارة)';
  static const String ipaTranscription = '[umˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3407_umpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung umpruefen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التدقيق أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
