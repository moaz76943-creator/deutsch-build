// Sovereign Polyglot Core - Task 3555 (Contractual Compliance)
class Task3555Engine {
  static const int taskId = 3555;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'einschreiben';
  static const String praeteritum = 'schrieb ein';
  static const String perfekt = 'hat eingeschrieben';
  static const String arabicTranslation = 'إدراج / دمج التدوين (العقود والإدارة)';
  static const String ipaTranscription = '[einˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3555_einschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung einschreiben.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التدوين أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
