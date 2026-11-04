// Sovereign Polyglot Core - Task 3507 (Contractual Compliance)
class Task3507Engine {
  static const int taskId = 3507;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'umnehmen';
  static const String praeteritum = 'nahm um';
  static const String perfekt = 'hat umgenommen';
  static const String arabicTranslation = 'إعادة هيكلة الاستلام (العقود والإدارة)';
  static const String ipaTranscription = '[umˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3507_umnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung umnehmen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة الاستلام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
