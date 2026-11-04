// Sovereign Polyglot Core - Task 3609 (Contractual Compliance)
class Task3609Engine {
  static const int taskId = 3609;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'zusammenziehen';
  static const String praeteritum = 'zog zusammen';
  static const String perfekt = 'hat zusammengezogen';
  static const String arabicTranslation = 'تجميع / توحيد الاستنتاج (العقود والإدارة)';
  static const String ipaTranscription = '[zusammenˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3609_zusammenziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung zusammenziehen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد الاستنتاج أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
