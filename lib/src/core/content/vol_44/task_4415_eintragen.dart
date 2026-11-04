// Sovereign Polyglot Core - Task 4415 (Supply Chain)
class Task4415Engine {
  static const int taskId = 4415;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'eintragen';
  static const String praeteritum = 'trug ein';
  static const String perfekt = 'hat eingetragen';
  static const String arabicTranslation = 'إدراج / دمج المسؤولية (سلاسل الإمداد)';
  static const String ipaTranscription = '[einˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4415_eintragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale eintragen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج المسؤولية في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
