// Sovereign Polyglot Core - Task 3602 (Contractual Compliance)
class Task3602Engine {
  static const int taskId = 3602;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'verziehen';
  static const String praeteritum = 'verzog';
  static const String perfekt = 'hat verzogen';
  static const String arabicTranslation = 'توثيق / معالجة الاستنتاج (العقود والإدارة)';
  static const String ipaTranscription = '[verˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3602_verziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung verziehen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة الاستنتاج أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
