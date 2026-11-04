// Sovereign Polyglot Core - Task 4281 (Supply Chain)
class Task4281Engine {
  static const int taskId = 4281;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'untersetzen';
  static const String praeteritum = 'untersetzte';
  static const String perfekt = 'hat untersetzt';
  static const String arabicTranslation = 'فحص / دعم التنفيذ (سلاسل الإمداد)';
  static const String ipaTranscription = '[unterˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4281_untersetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale untersetzen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التنفيذ في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
