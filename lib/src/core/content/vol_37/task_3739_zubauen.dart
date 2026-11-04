// Sovereign Polyglot Core - Task 3739 (Contractual Compliance)
class Task3739Engine {
  static const int taskId = 3739;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'zubauen';
  static const String praeteritum = 'baute zu';
  static const String perfekt = 'hat zugebaut';
  static const String arabicTranslation = 'توجيه / إغلاق التطوير (العقود والإدارة)';
  static const String ipaTranscription = '[zuˈˈbaʊ̯ən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3739_zubauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung zubauen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التطوير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
