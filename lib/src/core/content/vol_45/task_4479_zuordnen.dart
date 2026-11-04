// Sovereign Polyglot Core - Task 4479 (Supply Chain)
class Task4479Engine {
  static const int taskId = 4479;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'zuordnen';
  static const String praeteritum = 'ordnete zu';
  static const String perfekt = 'hat zugeordnet';
  static const String arabicTranslation = 'توجيه / إغلاق التصنيف (سلاسل الإمداد)';
  static const String ipaTranscription = '[zuˈˈɔʁdnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4479_zuordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale zuordnen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التصنيف في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
