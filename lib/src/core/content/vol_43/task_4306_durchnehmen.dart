// Sovereign Polyglot Core - Task 4306 (Supply Chain)
class Task4306Engine {
  static const int taskId = 4306;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'durchnehmen';
  static const String praeteritum = 'nahm durch';
  static const String perfekt = 'hat durchgenommen';
  static const String arabicTranslation = 'إتمام شامل الاستلام (سلاسل الإمداد)';
  static const String ipaTranscription = '[durchˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4306_durchnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale durchnehmen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل الاستلام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
