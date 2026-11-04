// Sovereign Polyglot Core - Task 4345 (Supply Chain)
class Task4345Engine {
  static const int taskId = 4345;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'erhalten';
  static const String praeteritum = 'erhielt';
  static const String perfekt = 'hat erhalten';
  static const String arabicTranslation = 'إنجاز / تحقيق الالتزام (سلاسل الإمداد)';
  static const String ipaTranscription = '[erˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4345_erhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale erhalten.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق الالتزام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
