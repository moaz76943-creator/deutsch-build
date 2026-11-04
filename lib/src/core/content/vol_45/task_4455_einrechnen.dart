// Sovereign Polyglot Core - Task 4455 (Supply Chain)
class Task4455Engine {
  static const int taskId = 4455;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'einrechnen';
  static const String praeteritum = 'rechnete ein';
  static const String perfekt = 'hat eingerechnet';
  static const String arabicTranslation = 'إدراج / دمج التقدير (سلاسل الإمداد)';
  static const String ipaTranscription = '[einˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4455_einrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale einrechnen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التقدير في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
