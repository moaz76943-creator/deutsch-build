// Sovereign Polyglot Core - Task 3607 (Contractual Compliance)
class Task3607Engine {
  static const int taskId = 3607;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'umziehen';
  static const String praeteritum = 'zog um';
  static const String perfekt = 'hat umgezogen';
  static const String arabicTranslation = 'إعادة هيكلة الاستنتاج (العقود والإدارة)';
  static const String ipaTranscription = '[umˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3607_umziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung umziehen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة الاستنتاج أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
