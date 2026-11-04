// Sovereign Polyglot Core - Task 4191 (Supply Chain)
class Task4191Engine {
  static const int taskId = 4191;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'abpruefen';
  static const String praeteritum = 'pruefte ab';
  static const String perfekt = 'hat abgeprueft';
  static const String arabicTranslation = 'فصل / إتمام التدقيق (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4191_abpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale abpruefen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التدقيق في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
