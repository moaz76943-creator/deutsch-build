// Sovereign Polyglot Core - Task 3403 (Contractual Compliance)
class Task3403Engine {
  static const int taskId = 3403;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'entpruefen';
  static const String praeteritum = 'entpruefte';
  static const String perfekt = 'hat entprueft';
  static const String arabicTranslation = 'استخلاص / كشف التدقيق (العقود والإدارة)';
  static const String ipaTranscription = '[entˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3403_entpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung entpruefen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التدقيق أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
