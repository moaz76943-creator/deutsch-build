// Sovereign Polyglot Core - Task 3617 (Contractual Compliance)
class Task3617Engine {
  static const int taskId = 3617;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'nachtragen';
  static const String praeteritum = 'trug nach';
  static const String perfekt = 'hat nachgetragen';
  static const String arabicTranslation = 'تدقيق / متابعة المسؤولية (العقود والإدارة)';
  static const String ipaTranscription = '[nachˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3617_nachtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung nachtragen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة المسؤولية أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
