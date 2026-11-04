// Sovereign Polyglot Core - Task 3405 (Contractual Compliance)
class Task3405Engine {
  static const int taskId = 3405;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'erpruefen';
  static const String praeteritum = 'erpruefte';
  static const String perfekt = 'hat erprueft';
  static const String arabicTranslation = 'إنجاز / تحقيق التدقيق (العقود والإدارة)';
  static const String ipaTranscription = '[erˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3405_erpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung erpruefen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التدقيق أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
