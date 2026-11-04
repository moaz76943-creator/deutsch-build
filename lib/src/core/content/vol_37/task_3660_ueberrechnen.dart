// Sovereign Polyglot Core - Task 3660 (Contractual Compliance)
class Task3660Engine {
  static const int taskId = 3660;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ueberrechnen';
  static const String praeteritum = 'ueberrechnete';
  static const String perfekt = 'hat ueberrechnet';
  static const String arabicTranslation = 'مراجعة / نقل التقدير (العقود والإدارة)';
  static const String ipaTranscription = '[ueberˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3660_ueberrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ueberrechnen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التقدير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
