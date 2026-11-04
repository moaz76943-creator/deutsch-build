// Sovereign Polyglot Core - Task 3480 (Contractual Compliance)
class Task3480Engine {
  static const int taskId = 3480;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'uebersetzen';
  static const String praeteritum = 'uebersetzte';
  static const String perfekt = 'hat uebersetzt';
  static const String arabicTranslation = 'مراجعة / نقل التنفيذ (العقود والإدارة)';
  static const String ipaTranscription = '[ueberˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3480_uebersetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung uebersetzen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التنفيذ أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
