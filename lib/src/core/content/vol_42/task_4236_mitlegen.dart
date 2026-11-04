// Sovereign Polyglot Core - Task 4236 (Supply Chain)
class Task4236Engine {
  static const int taskId = 4236;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'mitlegen';
  static const String praeteritum = 'legte mit';
  static const String perfekt = 'hat mitgelegt';
  static const String arabicTranslation = 'مشاركة / تنسيق التأسيس (سلاسل الإمداد)';
  static const String ipaTranscription = '[mitˈˈleːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4236_mitlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale mitlegen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التأسيس في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
