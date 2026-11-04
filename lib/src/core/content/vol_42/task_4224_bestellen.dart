// Sovereign Polyglot Core - Task 4224 (Supply Chain)
class Task4224Engine {
  static const int taskId = 4224;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'bestellen';
  static const String praeteritum = 'bestellte';
  static const String perfekt = 'hat bestellt';
  static const String arabicTranslation = 'تأكيد / تزويد التنظيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[beˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4224_bestellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale bestellen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التنظيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
