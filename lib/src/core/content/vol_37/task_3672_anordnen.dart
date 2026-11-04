// Sovereign Polyglot Core - Task 3672 (Contractual Compliance)
class Task3672Engine {
  static const int taskId = 3672;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'anordnen';
  static const String praeteritum = 'ordnete an';
  static const String perfekt = 'hat angeordnet';
  static const String arabicTranslation = 'بدء / توجيه التصنيف (العقود والإدارة)';
  static const String ipaTranscription = '[anˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3672_anordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung anordnen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التصنيف أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
