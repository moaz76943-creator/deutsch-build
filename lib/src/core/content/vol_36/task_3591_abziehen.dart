// Sovereign Polyglot Core - Task 3591 (Contractual Compliance)
class Task3591Engine {
  static const int taskId = 3591;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'abziehen';
  static const String praeteritum = 'zog ab';
  static const String perfekt = 'hat abgezogen';
  static const String arabicTranslation = 'فصل / إتمام الاستنتاج (العقود والإدارة)';
  static const String ipaTranscription = '[abˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3591_abziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung abziehen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الاستنتاج أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
