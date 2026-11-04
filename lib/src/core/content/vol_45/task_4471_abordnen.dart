// Sovereign Polyglot Core - Task 4471 (Supply Chain)
class Task4471Engine {
  static const int taskId = 4471;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'abordnen';
  static const String praeteritum = 'ordnete ab';
  static const String perfekt = 'hat abgeordnet';
  static const String arabicTranslation = 'فصل / إتمام التصنيف (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4471_abordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale abordnen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التصنيف في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
