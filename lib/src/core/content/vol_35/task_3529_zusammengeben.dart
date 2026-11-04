// Sovereign Polyglot Core - Task 3529 (Contractual Compliance)
class Task3529Engine {
  static const int taskId = 3529;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'zusammengeben';
  static const String praeteritum = 'gab zusammen';
  static const String perfekt = 'hat zusammengegeben';
  static const String arabicTranslation = 'تجميع / توحيد التسليم (العقود والإدارة)';
  static const String ipaTranscription = '[zusammenˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3529_zusammengeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung zusammengeben.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التسليم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
