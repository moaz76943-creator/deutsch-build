// Sovereign Polyglot Core - Task 4175 (Supply Chain)
class Task4175Engine {
  static const int taskId = 4175;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'einplanen';
  static const String praeteritum = 'plante ein';
  static const String perfekt = 'hat eingeplant';
  static const String arabicTranslation = 'إدراج / دمج التخطيط (سلاسل الإمداد)';
  static const String ipaTranscription = '[einˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4175_einplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale einplanen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التخطيط في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
