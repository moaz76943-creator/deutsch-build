// Sovereign Polyglot Core - Task 3565 (Contractual Compliance)
class Task3565Engine {
  static const int taskId = 3565;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'erschreiben';
  static const String praeteritum = 'erschrieb';
  static const String perfekt = 'hat erschrieben';
  static const String arabicTranslation = 'إنجاز / تحقيق التدوين (العقود والإدارة)';
  static const String ipaTranscription = '[erˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3565_erschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung erschreiben.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التدوين أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
