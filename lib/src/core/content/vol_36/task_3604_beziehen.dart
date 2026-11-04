// Sovereign Polyglot Core - Task 3604 (Contractual Compliance)
class Task3604Engine {
  static const int taskId = 3604;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'beziehen';
  static const String praeteritum = 'bezog';
  static const String perfekt = 'hat bezogen';
  static const String arabicTranslation = 'تأكيد / تزويد الاستنتاج (العقود والإدارة)';
  static const String ipaTranscription = '[beˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3604_beziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung beziehen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد الاستنتاج أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
