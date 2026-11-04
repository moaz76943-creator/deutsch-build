// Sovereign Polyglot Core - Task 4320 (Supply Chain)
class Task4320Engine {
  static const int taskId = 4320;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'uebergeben';
  static const String praeteritum = 'uebergab';
  static const String perfekt = 'hat uebergeben';
  static const String arabicTranslation = 'مراجعة / نقل التسليم (سلاسل الإمداد)';
  static const String ipaTranscription = '[ueberˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4320_uebergeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale uebergeben.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التسليم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
