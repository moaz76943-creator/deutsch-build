// Sovereign Polyglot Core - Task 3567 (Contractual Compliance)
class Task3567Engine {
  static const int taskId = 3567;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'umschreiben';
  static const String praeteritum = 'schrieb um';
  static const String perfekt = 'hat umgeschrieben';
  static const String arabicTranslation = 'إعادة هيكلة التدوين (العقود والإدارة)';
  static const String ipaTranscription = '[umˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3567_umschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung umschreiben.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التدوين أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
