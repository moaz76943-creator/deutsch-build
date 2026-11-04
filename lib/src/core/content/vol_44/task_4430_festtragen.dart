// Sovereign Polyglot Core - Task 4430 (Supply Chain)
class Task4430Engine {
  static const int taskId = 4430;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'festtragen';
  static const String praeteritum = 'trug fest';
  static const String perfekt = 'hat festgetragen';
  static const String arabicTranslation = 'تثبيت / إقرار المسؤولية (سلاسل الإمداد)';
  static const String ipaTranscription = '[festˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4430_festtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale festtragen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار المسؤولية في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
