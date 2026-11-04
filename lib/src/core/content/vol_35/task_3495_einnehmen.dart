// Sovereign Polyglot Core - Task 3495 (Contractual Compliance)
class Task3495Engine {
  static const int taskId = 3495;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'einnehmen';
  static const String praeteritum = 'nahm ein';
  static const String perfekt = 'hat eingenommen';
  static const String arabicTranslation = 'إدراج / دمج الاستلام (العقود والإدارة)';
  static const String ipaTranscription = '[einˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3495_einnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung einnehmen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الاستلام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
