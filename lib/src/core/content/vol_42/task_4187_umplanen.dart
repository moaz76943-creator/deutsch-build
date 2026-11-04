// Sovereign Polyglot Core - Task 4187 (Supply Chain)
class Task4187Engine {
  static const int taskId = 4187;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'umplanen';
  static const String praeteritum = 'plante um';
  static const String perfekt = 'hat umgeplant';
  static const String arabicTranslation = 'إعادة هيكلة التخطيط (سلاسل الإمداد)';
  static const String ipaTranscription = '[umˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4187_umplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale umplanen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التخطيط في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
