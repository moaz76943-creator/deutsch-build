// Sovereign Polyglot Core - Task 3645 (Contractual Compliance)
class Task3645Engine {
  static const int taskId = 3645;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'erweisen';
  static const String praeteritum = 'erwies';
  static const String perfekt = 'hat erwiesen';
  static const String arabicTranslation = 'إنجاز / تحقيق التوجيه (العقود والإدارة)';
  static const String ipaTranscription = '[erˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3645_erweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung erweisen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التوجيه أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
