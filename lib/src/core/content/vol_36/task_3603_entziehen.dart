// Sovereign Polyglot Core - Task 3603 (Contractual Compliance)
class Task3603Engine {
  static const int taskId = 3603;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'entziehen';
  static const String praeteritum = 'entzog';
  static const String perfekt = 'hat entzogen';
  static const String arabicTranslation = 'استخلاص / كشف الاستنتاج (العقود والإدارة)';
  static const String ipaTranscription = '[entˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3603_entziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung entziehen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الاستنتاج أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
