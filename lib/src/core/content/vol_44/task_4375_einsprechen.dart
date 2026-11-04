// Sovereign Polyglot Core - Task 4375 (Supply Chain)
class Task4375Engine {
  static const int taskId = 4375;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'einsprechen';
  static const String praeteritum = 'sprach ein';
  static const String perfekt = 'hat eingesprochen';
  static const String arabicTranslation = 'إدراج / دمج التخاطب (سلاسل الإمداد)';
  static const String ipaTranscription = '[einˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4375_einsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale einsprechen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التخاطب في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
