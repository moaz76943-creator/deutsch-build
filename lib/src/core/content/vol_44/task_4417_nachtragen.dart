// Sovereign Polyglot Core - Task 4417 (Supply Chain)
class Task4417Engine {
  static const int taskId = 4417;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'nachtragen';
  static const String praeteritum = 'trug nach';
  static const String perfekt = 'hat nachgetragen';
  static const String arabicTranslation = 'تدقيق / متابعة المسؤولية (سلاسل الإمداد)';
  static const String ipaTranscription = '[nachˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4417_nachtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale nachtragen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة المسؤولية في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
