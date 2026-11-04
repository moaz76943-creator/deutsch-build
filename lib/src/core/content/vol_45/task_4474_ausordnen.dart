// Sovereign Polyglot Core - Task 4474 (Supply Chain)
class Task4474Engine {
  static const int taskId = 4474;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ausordnen';
  static const String praeteritum = 'ordnete aus';
  static const String perfekt = 'hat ausgeordnet';
  static const String arabicTranslation = 'توسيع / استخراج التصنيف (سلاسل الإمداد)';
  static const String ipaTranscription = '[ausˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4474_ausordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ausordnen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التصنيف في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
