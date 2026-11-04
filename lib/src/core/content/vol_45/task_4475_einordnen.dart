// Sovereign Polyglot Core - Task 4475 (Supply Chain)
class Task4475Engine {
  static const int taskId = 4475;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'einordnen';
  static const String praeteritum = 'ordnete ein';
  static const String perfekt = 'hat eingeordnet';
  static const String arabicTranslation = 'إدراج / دمج التصنيف (سلاسل الإمداد)';
  static const String ipaTranscription = '[einˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4475_einordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale einordnen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التصنيف في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
