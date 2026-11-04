// Sovereign Polyglot Core - Task 4201 (Supply Chain)
class Task4201Engine {
  static const int taskId = 4201;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'unterpruefen';
  static const String praeteritum = 'unterpruefte';
  static const String perfekt = 'hat unterprueft';
  static const String arabicTranslation = 'فحص / دعم التدقيق (سلاسل الإمداد)';
  static const String ipaTranscription = '[unterˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4201_unterpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale unterpruefen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التدقيق في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
