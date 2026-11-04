// Sovereign Polyglot Core - Task 3441 (Contractual Compliance)
class Task3441Engine {
  static const int taskId = 3441;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'unterlegen';
  static const String praeteritum = 'unterlegte';
  static const String perfekt = 'hat unterlegt';
  static const String arabicTranslation = 'فحص / دعم التأسيس (العقود والإدارة)';
  static const String ipaTranscription = '[unterˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3441_unterlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung unterlegen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التأسيس أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
