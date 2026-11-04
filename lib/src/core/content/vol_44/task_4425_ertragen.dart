// Sovereign Polyglot Core - Task 4425 (Supply Chain)
class Task4425Engine {
  static const int taskId = 4425;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ertragen';
  static const String praeteritum = 'ertrug';
  static const String perfekt = 'hat ertragen';
  static const String arabicTranslation = 'إنجاز / تحقيق المسؤولية (سلاسل الإمداد)';
  static const String ipaTranscription = '[erˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4425_ertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ertragen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق المسؤولية في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
