// Sovereign Polyglot Core - Task 3679 (Contractual Compliance)
class Task3679Engine {
  static const int taskId = 3679;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'zuordnen';
  static const String praeteritum = 'ordnete zu';
  static const String perfekt = 'hat zugeordnet';
  static const String arabicTranslation = 'توجيه / إغلاق التصنيف (العقود والإدارة)';
  static const String ipaTranscription = '[zuˈˈɔʁdnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3679_zuordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung zuordnen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التصنيف أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
