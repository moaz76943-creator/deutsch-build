// Sovereign Polyglot Core - Task 4185 (Supply Chain)
class Task4185Engine {
  static const int taskId = 4185;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'erplanen';
  static const String praeteritum = 'erplante';
  static const String perfekt = 'hat erplant';
  static const String arabicTranslation = 'إنجاز / تحقيق التخطيط (سلاسل الإمداد)';
  static const String ipaTranscription = '[erˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4185_erplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale erplanen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التخطيط في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
