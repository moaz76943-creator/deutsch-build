// Sovereign Polyglot Core - Task 3720 (Contractual Compliance)
class Task3720Engine {
  static const int taskId = 3720;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ueberschliessen';
  static const String praeteritum = 'ueberschloss';
  static const String perfekt = 'hat ueberschlossen';
  static const String arabicTranslation = 'مراجعة / نقل الإبرام (العقود والإدارة)';
  static const String ipaTranscription = '[ueberˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3720_ueberschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ueberschliessen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الإبرام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
