// Sovereign Polyglot Core - Task 4372 (Supply Chain)
class Task4372Engine {
  static const int taskId = 4372;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ansprechen';
  static const String praeteritum = 'sprach an';
  static const String perfekt = 'hat angesprochen';
  static const String arabicTranslation = 'بدء / توجيه التخاطب (سلاسل الإمداد)';
  static const String ipaTranscription = '[anˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4372_ansprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ansprechen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التخاطب في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
