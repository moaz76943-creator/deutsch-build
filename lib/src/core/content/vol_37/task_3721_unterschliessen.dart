// Sovereign Polyglot Core - Task 3721 (Contractual Compliance)
class Task3721Engine {
  static const int taskId = 3721;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'unterschliessen';
  static const String praeteritum = 'unterschloss';
  static const String perfekt = 'hat unterschlossen';
  static const String arabicTranslation = 'فحص / دعم الإبرام (العقود والإدارة)';
  static const String ipaTranscription = '[unterˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3721_unterschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung unterschliessen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم الإبرام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
