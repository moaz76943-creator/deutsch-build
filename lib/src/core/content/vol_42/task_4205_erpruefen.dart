// Sovereign Polyglot Core - Task 4205 (Supply Chain)
class Task4205Engine {
  static const int taskId = 4205;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'erpruefen';
  static const String praeteritum = 'erpruefte';
  static const String perfekt = 'hat erprueft';
  static const String arabicTranslation = 'إنجاز / تحقيق التدقيق (سلاسل الإمداد)';
  static const String ipaTranscription = '[erˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4205_erpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale erpruefen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التدقيق في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
