// Sovereign Polyglot Core - Task 3606 (Contractual Compliance)
class Task3606Engine {
  static const int taskId = 3606;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'durchziehen';
  static const String praeteritum = 'zog durch';
  static const String perfekt = 'hat durchgezogen';
  static const String arabicTranslation = 'إتمام شامل الاستنتاج (العقود والإدارة)';
  static const String ipaTranscription = '[durchˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3606_durchziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung durchziehen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل الاستنتاج أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
