// Sovereign Polyglot Core - Task 3733 (Contractual Compliance)
class Task3733Engine {
  static const int taskId = 3733;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'aufbauen';
  static const String praeteritum = 'baute auf';
  static const String perfekt = 'hat aufgebaut';
  static const String arabicTranslation = 'رفع / فتح التطوير (العقود والإدارة)';
  static const String ipaTranscription = '[aufˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3733_aufbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung aufbauen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التطوير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
