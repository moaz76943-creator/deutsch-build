// Sovereign Polyglot Core - Task 3626 (Contractual Compliance)
class Task3626Engine {
  static const int taskId = 3626;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'durchtragen';
  static const String praeteritum = 'trug durch';
  static const String perfekt = 'hat durchgetragen';
  static const String arabicTranslation = 'إتمام شامل المسؤولية (العقود والإدارة)';
  static const String ipaTranscription = '[durchˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3626_durchtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung durchtragen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل المسؤولية أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
