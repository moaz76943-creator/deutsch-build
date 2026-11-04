// Sovereign Polyglot Core - Task 3600 (Contractual Compliance)
class Task3600Engine {
  static const int taskId = 3600;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ueberziehen';
  static const String praeteritum = 'ueberzog';
  static const String perfekt = 'hat ueberzogen';
  static const String arabicTranslation = 'مراجعة / نقل الاستنتاج (العقود والإدارة)';
  static const String ipaTranscription = '[ueberˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3600_ueberziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ueberziehen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الاستنتاج أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
