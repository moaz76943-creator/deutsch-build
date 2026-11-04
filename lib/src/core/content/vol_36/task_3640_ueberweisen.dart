// Sovereign Polyglot Core - Task 3640 (Contractual Compliance)
class Task3640Engine {
  static const int taskId = 3640;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ueberweisen';
  static const String praeteritum = 'ueberwies';
  static const String perfekt = 'hat ueberwiesen';
  static const String arabicTranslation = 'مراجعة / نقل التوجيه (العقود والإدارة)';
  static const String ipaTranscription = '[ueberˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3640_ueberweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ueberweisen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التوجيه أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
