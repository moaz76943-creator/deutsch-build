// Sovereign Polyglot Core - Task 3703 (Contractual Compliance)
class Task3703Engine {
  static const int taskId = 3703;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'entteilen';
  static const String praeteritum = 'entteilte';
  static const String perfekt = 'hat entteilt';
  static const String arabicTranslation = 'استخلاص / كشف التقسيم (العقود والإدارة)';
  static const String ipaTranscription = '[entˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3703_entteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung entteilen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التقسيم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
