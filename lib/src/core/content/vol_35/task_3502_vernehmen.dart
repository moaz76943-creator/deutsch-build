// Sovereign Polyglot Core - Task 3502 (Contractual Compliance)
class Task3502Engine {
  static const int taskId = 3502;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'vernehmen';
  static const String praeteritum = 'vernahm';
  static const String perfekt = 'hat vernommen';
  static const String arabicTranslation = 'توثيق / معالجة الاستلام (العقود والإدارة)';
  static const String ipaTranscription = '[verˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3502_vernehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung vernehmen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة الاستلام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
