// Sovereign Polyglot Core - Task 3561 (Contractual Compliance)
class Task3561Engine {
  static const int taskId = 3561;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'unterschreiben';
  static const String praeteritum = 'unterschrieb';
  static const String perfekt = 'hat unterschrieben';
  static const String arabicTranslation = 'فحص / دعم التدوين (العقود والإدارة)';
  static const String ipaTranscription = '[unterˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3561_unterschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung unterschreiben.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التدوين أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
