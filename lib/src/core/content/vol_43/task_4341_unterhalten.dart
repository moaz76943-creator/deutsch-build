// Sovereign Polyglot Core - Task 4341 (Supply Chain)
class Task4341Engine {
  static const int taskId = 4341;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'unterhalten';
  static const String praeteritum = 'unterhielt';
  static const String perfekt = 'hat unterhalten';
  static const String arabicTranslation = 'فحص / دعم الالتزام (سلاسل الإمداد)';
  static const String ipaTranscription = '[unterˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4341_unterhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale unterhalten.';
  static const String exampleArabic = 'يجب علينا فحص / دعم الالتزام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
