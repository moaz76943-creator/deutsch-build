// Sovereign Polyglot Core - Task 4421 (Supply Chain)
class Task4421Engine {
  static const int taskId = 4421;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'untertragen';
  static const String praeteritum = 'untertrug';
  static const String perfekt = 'hat untertragen';
  static const String arabicTranslation = 'فحص / دعم المسؤولية (سلاسل الإمداد)';
  static const String ipaTranscription = '[unterˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4421_untertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale untertragen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم المسؤولية في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
