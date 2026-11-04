// Sovereign Polyglot Core - Task 4208 (Supply Chain)
class Task4208Engine {
  static const int taskId = 4208;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'weiterpruefen';
  static const String praeteritum = 'pruefte weiter';
  static const String perfekt = 'hat weitergeprueft';
  static const String arabicTranslation = 'مواصلة / تمرير التدقيق (سلاسل الإمداد)';
  static const String ipaTranscription = '[weiterˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4208_weiterpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale weiterpruefen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التدقيق في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
