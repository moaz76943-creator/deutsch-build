// Sovereign Polyglot Core - Task 4374 (Supply Chain)
class Task4374Engine {
  static const int taskId = 4374;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'aussprechen';
  static const String praeteritum = 'sprach aus';
  static const String perfekt = 'hat ausgesprochen';
  static const String arabicTranslation = 'توسيع / استخراج التخاطب (سلاسل الإمداد)';
  static const String ipaTranscription = '[ausˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4374_aussprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale aussprechen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التخاطب في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
