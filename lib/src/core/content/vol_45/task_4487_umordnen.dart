// Sovereign Polyglot Core - Task 4487 (Supply Chain)
class Task4487Engine {
  static const int taskId = 4487;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'umordnen';
  static const String praeteritum = 'ordnete um';
  static const String perfekt = 'hat umgeordnet';
  static const String arabicTranslation = 'إعادة هيكلة التصنيف (سلاسل الإمداد)';
  static const String ipaTranscription = '[umˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4487_umordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale umordnen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التصنيف في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
