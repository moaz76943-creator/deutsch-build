// Sovereign Polyglot Core - Task 4303 (Supply Chain)
class Task4303Engine {
  static const int taskId = 4303;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'entnehmen';
  static const String praeteritum = 'entnahm';
  static const String perfekt = 'hat entnommen';
  static const String arabicTranslation = 'استخلاص / كشف الاستلام (سلاسل الإمداد)';
  static const String ipaTranscription = '[entˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4303_entnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale entnehmen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الاستلام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
