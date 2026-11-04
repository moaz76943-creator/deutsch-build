// Sovereign Polyglot Core - Task 3675 (Contractual Compliance)
class Task3675Engine {
  static const int taskId = 3675;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'einordnen';
  static const String praeteritum = 'ordnete ein';
  static const String perfekt = 'hat eingeordnet';
  static const String arabicTranslation = 'إدراج / دمج التصنيف (العقود والإدارة)';
  static const String ipaTranscription = '[einˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3675_einordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung einordnen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التصنيف أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
