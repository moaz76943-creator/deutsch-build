// Sovereign Polyglot Core - Task 3611 (Contractual Compliance)
class Task3611Engine {
  static const int taskId = 3611;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'abtragen';
  static const String praeteritum = 'trug ab';
  static const String perfekt = 'hat abgetragen';
  static const String arabicTranslation = 'فصل / إتمام المسؤولية (العقود والإدارة)';
  static const String ipaTranscription = '[abˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3611_abtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung abtragen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام المسؤولية أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
