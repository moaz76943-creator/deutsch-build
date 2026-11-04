// Sovereign Polyglot Core - Task 3460 (Contractual Compliance)
class Task3460Engine {
  static const int taskId = 3460;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ueberfuehren';
  static const String praeteritum = 'ueberfuehrte';
  static const String perfekt = 'hat ueberfuehrt';
  static const String arabicTranslation = 'مراجعة / نقل الإدارة (العقود والإدارة)';
  static const String ipaTranscription = '[ueberˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3460_ueberfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ueberfuehren.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الإدارة أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
