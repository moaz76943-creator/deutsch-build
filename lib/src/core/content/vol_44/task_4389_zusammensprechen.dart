// Sovereign Polyglot Core - Task 4389 (Supply Chain)
class Task4389Engine {
  static const int taskId = 4389;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'zusammensprechen';
  static const String praeteritum = 'sprach zusammen';
  static const String perfekt = 'hat zusammengesprochen';
  static const String arabicTranslation = 'تجميع / توحيد التخاطب (سلاسل الإمداد)';
  static const String ipaTranscription = '[zusammenˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4389_zusammensprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale zusammensprechen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التخاطب في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
