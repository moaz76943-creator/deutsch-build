// Sovereign Polyglot Core - Task 4443 (Supply Chain)
class Task4443Engine {
  static const int taskId = 4443;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'entweisen';
  static const String praeteritum = 'entwies';
  static const String perfekt = 'hat entwiesen';
  static const String arabicTranslation = 'استخلاص / كشف التوجيه (سلاسل الإمداد)';
  static const String ipaTranscription = '[entˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4443_entweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale entweisen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التوجيه في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
