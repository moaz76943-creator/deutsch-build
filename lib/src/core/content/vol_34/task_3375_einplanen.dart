// Sovereign Polyglot Core - Task 3375 (Contractual Compliance)
class Task3375Engine {
  static const int taskId = 3375;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'einplanen';
  static const String praeteritum = 'plante ein';
  static const String perfekt = 'hat eingeplant';
  static const String arabicTranslation = 'إدراج / دمج التخطيط (العقود والإدارة)';
  static const String ipaTranscription = '[einˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3375_einplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung einplanen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التخطيط أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
