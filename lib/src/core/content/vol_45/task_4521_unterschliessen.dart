// Sovereign Polyglot Core - Task 4521 (Supply Chain)
class Task4521Engine {
  static const int taskId = 4521;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'unterschliessen';
  static const String praeteritum = 'unterschloss';
  static const String perfekt = 'hat unterschlossen';
  static const String arabicTranslation = 'فحص / دعم الإبرام (سلاسل الإمداد)';
  static const String ipaTranscription = '[unterˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4521_unterschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale unterschliessen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم الإبرام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
