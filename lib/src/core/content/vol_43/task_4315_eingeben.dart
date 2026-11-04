// Sovereign Polyglot Core - Task 4315 (Supply Chain)
class Task4315Engine {
  static const int taskId = 4315;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'eingeben';
  static const String praeteritum = 'gab ein';
  static const String perfekt = 'hat eingegeben';
  static const String arabicTranslation = 'إدراج / دمج التسليم (سلاسل الإمداد)';
  static const String ipaTranscription = '[einˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4315_eingeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale eingeben.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التسليم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
