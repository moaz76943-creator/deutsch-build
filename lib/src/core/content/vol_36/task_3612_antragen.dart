// Sovereign Polyglot Core - Task 3612 (Contractual Compliance)
class Task3612Engine {
  static const int taskId = 3612;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'antragen';
  static const String praeteritum = 'trug an';
  static const String perfekt = 'hat angetragen';
  static const String arabicTranslation = 'بدء / توجيه المسؤولية (العقود والإدارة)';
  static const String ipaTranscription = '[anˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3612_antragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung antragen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه المسؤولية أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
