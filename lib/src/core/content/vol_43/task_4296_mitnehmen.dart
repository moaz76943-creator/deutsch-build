// Sovereign Polyglot Core - Task 4296 (Supply Chain)
class Task4296Engine {
  static const int taskId = 4296;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'mitnehmen';
  static const String praeteritum = 'nahm mit';
  static const String perfekt = 'hat mitgenommen';
  static const String arabicTranslation = 'مشاركة / تنسيق الاستلام (سلاسل الإمداد)';
  static const String ipaTranscription = '[mitˈˈneːmən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4296_mitnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale mitnehmen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق الاستلام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
