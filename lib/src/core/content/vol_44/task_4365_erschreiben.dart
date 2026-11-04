// Sovereign Polyglot Core - Task 4365 (Supply Chain)
class Task4365Engine {
  static const int taskId = 4365;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'erschreiben';
  static const String praeteritum = 'erschrieb';
  static const String perfekt = 'hat erschrieben';
  static const String arabicTranslation = 'إنجاز / تحقيق التدوين (سلاسل الإمداد)';
  static const String ipaTranscription = '[erˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4365_erschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale erschreiben.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التدوين في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
