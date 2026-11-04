// Sovereign Polyglot Core - Task 4339 (Supply Chain)
class Task4339Engine {
  static const int taskId = 4339;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'zuhalten';
  static const String praeteritum = 'hielt zu';
  static const String perfekt = 'hat zugehalten';
  static const String arabicTranslation = 'توجيه / إغلاق الالتزام (سلاسل الإمداد)';
  static const String ipaTranscription = '[zuˈˈhaltn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4339_zuhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale zuhalten.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق الالتزام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
