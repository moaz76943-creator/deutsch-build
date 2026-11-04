// Sovereign Polyglot Core - Task 4214 (Supply Chain)
class Task4214Engine {
  static const int taskId = 4214;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ausstellen';
  static const String praeteritum = 'stellte aus';
  static const String perfekt = 'hat ausgestellt';
  static const String arabicTranslation = 'توسيع / استخراج التنظيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[ausˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4214_ausstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ausstellen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التنظيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
