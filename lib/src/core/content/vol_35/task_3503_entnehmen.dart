// Sovereign Polyglot Core - Task 3503 (Contractual Compliance)
class Task3503Engine {
  static const int taskId = 3503;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'entnehmen';
  static const String praeteritum = 'entnahm';
  static const String perfekt = 'hat entnommen';
  static const String arabicTranslation = 'استخلاص / كشف الاستلام (العقود والإدارة)';
  static const String ipaTranscription = '[entˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3503_entnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung entnehmen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الاستلام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
