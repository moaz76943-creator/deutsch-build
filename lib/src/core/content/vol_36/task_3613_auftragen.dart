// Sovereign Polyglot Core - Task 3613 (Contractual Compliance)
class Task3613Engine {
  static const int taskId = 3613;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'auftragen';
  static const String praeteritum = 'trug auf';
  static const String perfekt = 'hat aufgetragen';
  static const String arabicTranslation = 'رفع / فتح المسؤولية (العقود والإدارة)';
  static const String ipaTranscription = '[aufˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3613_auftragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung auftragen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح المسؤولية أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
