// Sovereign Polyglot Core - Task 4307 (Supply Chain)
class Task4307Engine {
  static const int taskId = 4307;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'umnehmen';
  static const String praeteritum = 'nahm um';
  static const String perfekt = 'hat umgenommen';
  static const String arabicTranslation = 'إعادة هيكلة الاستلام (سلاسل الإمداد)';
  static const String ipaTranscription = '[umˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4307_umnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale umnehmen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة الاستلام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
