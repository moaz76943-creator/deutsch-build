// Sovereign Polyglot Core - Task 4274 (Supply Chain)
class Task4274Engine {
  static const int taskId = 4274;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'aussetzen';
  static const String praeteritum = 'setzte aus';
  static const String perfekt = 'hat ausgesetzt';
  static const String arabicTranslation = 'توسيع / استخراج التنفيذ (سلاسل الإمداد)';
  static const String ipaTranscription = '[ausˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4274_aussetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale aussetzen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التنفيذ في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
