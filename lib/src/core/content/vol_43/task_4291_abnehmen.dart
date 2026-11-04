// Sovereign Polyglot Core - Task 4291 (Supply Chain)
class Task4291Engine {
  static const int taskId = 4291;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'abnehmen';
  static const String praeteritum = 'nahm ab';
  static const String perfekt = 'hat abgenommen';
  static const String arabicTranslation = 'فصل / إتمام الاستلام (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4291_abnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale abnehmen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الاستلام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
