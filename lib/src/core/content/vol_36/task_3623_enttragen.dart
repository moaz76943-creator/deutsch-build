// Sovereign Polyglot Core - Task 3623 (Contractual Compliance)
class Task3623Engine {
  static const int taskId = 3623;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'enttragen';
  static const String praeteritum = 'enttrug';
  static const String perfekt = 'hat enttragen';
  static const String arabicTranslation = 'استخلاص / كشف المسؤولية (العقود والإدارة)';
  static const String ipaTranscription = '[entˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3623_enttragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung enttragen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف المسؤولية أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
