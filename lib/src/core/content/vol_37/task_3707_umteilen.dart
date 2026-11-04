// Sovereign Polyglot Core - Task 3707 (Contractual Compliance)
class Task3707Engine {
  static const int taskId = 3707;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'umteilen';
  static const String praeteritum = 'teilte um';
  static const String perfekt = 'hat umgeteilt';
  static const String arabicTranslation = 'إعادة هيكلة التقسيم (العقود والإدارة)';
  static const String ipaTranscription = '[umˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3707_umteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung umteilen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التقسيم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
