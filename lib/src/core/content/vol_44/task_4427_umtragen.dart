// Sovereign Polyglot Core - Task 4427 (Supply Chain)
class Task4427Engine {
  static const int taskId = 4427;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'umtragen';
  static const String praeteritum = 'trug um';
  static const String perfekt = 'hat umgetragen';
  static const String arabicTranslation = 'إعادة هيكلة المسؤولية (سلاسل الإمداد)';
  static const String ipaTranscription = '[umˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4427_umtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale umtragen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة المسؤولية في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
