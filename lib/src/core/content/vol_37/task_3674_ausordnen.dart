// Sovereign Polyglot Core - Task 3674 (Contractual Compliance)
class Task3674Engine {
  static const int taskId = 3674;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ausordnen';
  static const String praeteritum = 'ordnete aus';
  static const String perfekt = 'hat ausgeordnet';
  static const String arabicTranslation = 'توسيع / استخراج التصنيف (العقود والإدارة)';
  static const String ipaTranscription = '[ausˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3674_ausordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ausordnen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التصنيف أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
