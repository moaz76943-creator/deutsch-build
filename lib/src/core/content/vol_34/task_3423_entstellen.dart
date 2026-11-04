// Sovereign Polyglot Core - Task 3423 (Contractual Compliance)
class Task3423Engine {
  static const int taskId = 3423;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'entstellen';
  static const String praeteritum = 'entstellte';
  static const String perfekt = 'hat entstellt';
  static const String arabicTranslation = 'استخلاص / كشف التنظيم (العقود والإدارة)';
  static const String ipaTranscription = '[entˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3423_entstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung entstellen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التنظيم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
