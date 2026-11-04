// Sovereign Polyglot Core - Task 4451 (Supply Chain)
class Task4451Engine {
  static const int taskId = 4451;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'abrechnen';
  static const String praeteritum = 'rechnete ab';
  static const String perfekt = 'hat abgerechnet';
  static const String arabicTranslation = 'فصل / إتمام التقدير (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4451_abrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale abrechnen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التقدير في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
