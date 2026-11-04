// Sovereign Polyglot Core - Task 4411 (Supply Chain)
class Task4411Engine {
  static const int taskId = 4411;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'abtragen';
  static const String praeteritum = 'trug ab';
  static const String perfekt = 'hat abgetragen';
  static const String arabicTranslation = 'فصل / إتمام المسؤولية (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4411_abtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale abtragen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام المسؤولية في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
