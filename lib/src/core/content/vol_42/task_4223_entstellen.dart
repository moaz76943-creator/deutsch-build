// Sovereign Polyglot Core - Task 4223 (Supply Chain)
class Task4223Engine {
  static const int taskId = 4223;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'entstellen';
  static const String praeteritum = 'entstellte';
  static const String perfekt = 'hat entstellt';
  static const String arabicTranslation = 'استخلاص / كشف التنظيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[entˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4223_entstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale entstellen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التنظيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
