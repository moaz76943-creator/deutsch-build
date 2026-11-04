// Sovereign Polyglot Core - Task 4327 (Supply Chain)
class Task4327Engine {
  static const int taskId = 4327;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'umgeben';
  static const String praeteritum = 'gab um';
  static const String perfekt = 'hat umgegeben';
  static const String arabicTranslation = 'إعادة هيكلة التسليم (سلاسل الإمداد)';
  static const String ipaTranscription = '[umˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4327_umgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale umgeben.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التسليم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
