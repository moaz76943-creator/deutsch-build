// Sovereign Polyglot Core - Task 4304 (Supply Chain)
class Task4304Engine {
  static const int taskId = 4304;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'benehmen';
  static const String praeteritum = 'benahm';
  static const String perfekt = 'hat benommen';
  static const String arabicTranslation = 'تأكيد / تزويد الاستلام (سلاسل الإمداد)';
  static const String ipaTranscription = '[beˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4304_benehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale benehmen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد الاستلام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
