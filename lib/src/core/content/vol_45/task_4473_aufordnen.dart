// Sovereign Polyglot Core - Task 4473 (Supply Chain)
class Task4473Engine {
  static const int taskId = 4473;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'aufordnen';
  static const String praeteritum = 'ordnete auf';
  static const String perfekt = 'hat aufgeordnet';
  static const String arabicTranslation = 'رفع / فتح التصنيف (سلاسل الإمداد)';
  static const String ipaTranscription = '[aufˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4473_aufordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale aufordnen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التصنيف في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
