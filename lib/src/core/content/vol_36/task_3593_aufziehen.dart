// Sovereign Polyglot Core - Task 3593 (Contractual Compliance)
class Task3593Engine {
  static const int taskId = 3593;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'aufziehen';
  static const String praeteritum = 'zog auf';
  static const String perfekt = 'hat aufgezogen';
  static const String arabicTranslation = 'رفع / فتح الاستنتاج (العقود والإدارة)';
  static const String ipaTranscription = '[aufˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3593_aufziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung aufziehen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح الاستنتاج أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
