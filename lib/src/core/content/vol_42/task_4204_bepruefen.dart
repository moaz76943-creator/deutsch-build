// Sovereign Polyglot Core - Task 4204 (Supply Chain)
class Task4204Engine {
  static const int taskId = 4204;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'bepruefen';
  static const String praeteritum = 'bepruefte';
  static const String perfekt = 'hat beprueft';
  static const String arabicTranslation = 'تأكيد / تزويد التدقيق (سلاسل الإمداد)';
  static const String ipaTranscription = '[beˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4204_bepruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale bepruefen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التدقيق في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
