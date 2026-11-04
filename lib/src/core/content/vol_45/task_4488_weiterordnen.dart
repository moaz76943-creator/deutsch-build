// Sovereign Polyglot Core - Task 4488 (Supply Chain)
class Task4488Engine {
  static const int taskId = 4488;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'weiterordnen';
  static const String praeteritum = 'ordnete weiter';
  static const String perfekt = 'hat weitergeordnet';
  static const String arabicTranslation = 'مواصلة / تمرير التصنيف (سلاسل الإمداد)';
  static const String ipaTranscription = '[weiterˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4488_weiterordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale weiterordnen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التصنيف في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
