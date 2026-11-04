// Sovereign Polyglot Core - Task 4477 (Supply Chain)
class Task4477Engine {
  static const int taskId = 4477;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'nachordnen';
  static const String praeteritum = 'ordnete nach';
  static const String perfekt = 'hat nachgeordnet';
  static const String arabicTranslation = 'تدقيق / متابعة التصنيف (سلاسل الإمداد)';
  static const String ipaTranscription = '[nachˈˈɔʁdnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4477_nachordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale nachordnen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التصنيف في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
