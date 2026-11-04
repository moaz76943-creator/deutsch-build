// Sovereign Polyglot Core - Task 2888 (Clinical Diagnostics)
class Task2888Engine {
  static const int taskId = 2888;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'weiterordnen';
  static const String praeteritum = 'ordnete weiter';
  static const String perfekt = 'hat weitergeordnet';
  static const String arabicTranslation = 'مواصلة / تمرير التصنيف (التواصل الطبي)';
  static const String ipaTranscription = '[weiterˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2888_weiterordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung weiterordnen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التصنيف في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
