// Sovereign Polyglot Core - Task 3381 (Contractual Compliance)
class Task3381Engine {
  static const int taskId = 3381;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'unterplanen';
  static const String praeteritum = 'unterplante';
  static const String perfekt = 'hat unterplant';
  static const String arabicTranslation = 'فحص / دعم التخطيط (العقود والإدارة)';
  static const String ipaTranscription = '[unterˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3381_unterplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung unterplanen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التخطيط أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
