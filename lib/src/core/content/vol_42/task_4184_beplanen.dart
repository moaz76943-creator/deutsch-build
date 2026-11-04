// Sovereign Polyglot Core - Task 4184 (Supply Chain)
class Task4184Engine {
  static const int taskId = 4184;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'beplanen';
  static const String praeteritum = 'beplante';
  static const String perfekt = 'hat beplant';
  static const String arabicTranslation = 'تأكيد / تزويد التخطيط (سلاسل الإمداد)';
  static const String ipaTranscription = '[beˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4184_beplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale beplanen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التخطيط في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
