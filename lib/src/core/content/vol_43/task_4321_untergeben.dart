// Sovereign Polyglot Core - Task 4321 (Supply Chain)
class Task4321Engine {
  static const int taskId = 4321;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'untergeben';
  static const String praeteritum = 'untergab';
  static const String perfekt = 'hat untergeben';
  static const String arabicTranslation = 'فحص / دعم التسليم (سلاسل الإمداد)';
  static const String ipaTranscription = '[unterˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4321_untergeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale untergeben.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التسليم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
