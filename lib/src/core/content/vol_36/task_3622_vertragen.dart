// Sovereign Polyglot Core - Task 3622 (Contractual Compliance)
class Task3622Engine {
  static const int taskId = 3622;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'vertragen';
  static const String praeteritum = 'vertrug';
  static const String perfekt = 'hat vertragen';
  static const String arabicTranslation = 'توثيق / معالجة المسؤولية (العقود والإدارة)';
  static const String ipaTranscription = '[verˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3622_vertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung vertragen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة المسؤولية أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
