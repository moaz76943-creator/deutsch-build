// Sovereign Polyglot Core - Task 3641 (Contractual Compliance)
class Task3641Engine {
  static const int taskId = 3641;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'unterweisen';
  static const String praeteritum = 'unterwies';
  static const String perfekt = 'hat unterwiesen';
  static const String arabicTranslation = 'فحص / دعم التوجيه (العقود والإدارة)';
  static const String ipaTranscription = '[unterˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3641_unterweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung unterweisen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التوجيه أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
