// Sovereign Polyglot Core - Task 4337 (Supply Chain)
class Task4337Engine {
  static const int taskId = 4337;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'nachhalten';
  static const String praeteritum = 'hielt nach';
  static const String perfekt = 'hat nachgehalten';
  static const String arabicTranslation = 'تدقيق / متابعة الالتزام (سلاسل الإمداد)';
  static const String ipaTranscription = '[nachˈˈhaltn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4337_nachhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale nachhalten.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة الالتزام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
