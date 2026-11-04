// Sovereign Polyglot Core - Task 4331 (Supply Chain)
class Task4331Engine {
  static const int taskId = 4331;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'abhalten';
  static const String praeteritum = 'hielt ab';
  static const String perfekt = 'hat abgehalten';
  static const String arabicTranslation = 'فصل / إتمام الالتزام (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4331_abhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale abhalten.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الالتزام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
