// Sovereign Polyglot Core - Task 4334 (Supply Chain)
class Task4334Engine {
  static const int taskId = 4334;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'aushalten';
  static const String praeteritum = 'hielt aus';
  static const String perfekt = 'hat ausgehalten';
  static const String arabicTranslation = 'توسيع / استخراج الالتزام (سلاسل الإمداد)';
  static const String ipaTranscription = '[ausˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4334_aushalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale aushalten.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج الالتزام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
