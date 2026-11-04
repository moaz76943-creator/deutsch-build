// Sovereign Polyglot Core - Task 3671 (Contractual Compliance)
class Task3671Engine {
  static const int taskId = 3671;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'abordnen';
  static const String praeteritum = 'ordnete ab';
  static const String perfekt = 'hat abgeordnet';
  static const String arabicTranslation = 'فصل / إتمام التصنيف (العقود والإدارة)';
  static const String ipaTranscription = '[abˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3671_abordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung abordnen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التصنيف أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
