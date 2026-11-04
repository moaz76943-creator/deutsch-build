// Sovereign Polyglot Core - Task 2488 (Software Architecture)
class Task2488Engine {
  static const int taskId = 2488;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'weiterordnen';
  static const String praeteritum = 'ordnete weiter';
  static const String perfekt = 'hat weitergeordnet';
  static const String arabicTranslation = 'مواصلة / تمرير التصنيف (هندسة البرمجيات)';
  static const String ipaTranscription = '[weiterˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2488_weiterordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review weiterordnen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التصنيف في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
