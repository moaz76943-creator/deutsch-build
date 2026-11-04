// Sovereign Polyglot Core - Task 3383 (Contractual Compliance)
class Task3383Engine {
  static const int taskId = 3383;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'entplanen';
  static const String praeteritum = 'entplante';
  static const String perfekt = 'hat entplant';
  static const String arabicTranslation = 'استخلاص / كشف التخطيط (العقود والإدارة)';
  static const String ipaTranscription = '[entˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3383_entplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung entplanen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التخطيط أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
