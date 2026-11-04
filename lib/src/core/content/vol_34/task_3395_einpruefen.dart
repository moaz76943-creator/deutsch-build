// Sovereign Polyglot Core - Task 3395 (Contractual Compliance)
class Task3395Engine {
  static const int taskId = 3395;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'einpruefen';
  static const String praeteritum = 'pruefte ein';
  static const String perfekt = 'hat eingeprueft';
  static const String arabicTranslation = 'إدراج / دمج التدقيق (العقود والإدارة)';
  static const String ipaTranscription = '[einˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3395_einpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung einpruefen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التدقيق أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
