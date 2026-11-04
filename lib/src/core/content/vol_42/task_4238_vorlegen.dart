// Sovereign Polyglot Core - Task 4238 (Supply Chain)
class Task4238Engine {
  static const int taskId = 4238;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'vorlegen';
  static const String praeteritum = 'legte vor';
  static const String perfekt = 'hat vorgelegt';
  static const String arabicTranslation = 'تقديم / تحضير التأسيس (سلاسل الإمداد)';
  static const String ipaTranscription = '[vorˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4238_vorlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale vorlegen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التأسيس في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
