// Sovereign Polyglot Core - Task 3711 (Contractual Compliance)
class Task3711Engine {
  static const int taskId = 3711;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'abschliessen';
  static const String praeteritum = 'schloss ab';
  static const String perfekt = 'hat abgeschlossen';
  static const String arabicTranslation = 'فصل / إتمام الإبرام (العقود والإدارة)';
  static const String ipaTranscription = '[abˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3711_abschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung abschliessen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الإبرام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
