// Sovereign Polyglot Core - Task 3523 (Contractual Compliance)
class Task3523Engine {
  static const int taskId = 3523;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'entgeben';
  static const String praeteritum = 'entgab';
  static const String perfekt = 'hat entgeben';
  static const String arabicTranslation = 'استخلاص / كشف التسليم (العقود والإدارة)';
  static const String ipaTranscription = '[entˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3523_entgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung entgeben.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التسليم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
