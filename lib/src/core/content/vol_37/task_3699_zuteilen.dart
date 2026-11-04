// Sovereign Polyglot Core - Task 3699 (Contractual Compliance)
class Task3699Engine {
  static const int taskId = 3699;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'zuteilen';
  static const String praeteritum = 'teilte zu';
  static const String perfekt = 'hat zugeteilt';
  static const String arabicTranslation = 'توجيه / إغلاق التقسيم (العقود والإدارة)';
  static const String ipaTranscription = '[zuˈˈtaɪ̯lən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3699_zuteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung zuteilen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التقسيم أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
