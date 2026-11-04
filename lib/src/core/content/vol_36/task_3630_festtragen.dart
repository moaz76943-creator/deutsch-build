// Sovereign Polyglot Core - Task 3630 (Contractual Compliance)
class Task3630Engine {
  static const int taskId = 3630;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'festtragen';
  static const String praeteritum = 'trug fest';
  static const String perfekt = 'hat festgetragen';
  static const String arabicTranslation = 'تثبيت / إقرار المسؤولية (العقود والإدارة)';
  static const String ipaTranscription = '[festˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3630_festtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung festtragen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار المسؤولية أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
