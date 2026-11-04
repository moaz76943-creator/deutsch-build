// Sovereign Polyglot Core - Task 4484 (Supply Chain)
class Task4484Engine {
  static const int taskId = 4484;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'beordnen';
  static const String praeteritum = 'beordnete';
  static const String perfekt = 'hat beordnet';
  static const String arabicTranslation = 'تأكيد / تزويد التصنيف (سلاسل الإمداد)';
  static const String ipaTranscription = '[beˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4484_beordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale beordnen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التصنيف في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
