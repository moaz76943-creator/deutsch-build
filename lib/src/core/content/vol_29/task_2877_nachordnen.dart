// Sovereign Polyglot Core - Task 2877 (Clinical Diagnostics)
class Task2877Engine {
  static const int taskId = 2877;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'nachordnen';
  static const String praeteritum = 'ordnete nach';
  static const String perfekt = 'hat nachgeordnet';
  static const String arabicTranslation = 'تدقيق / متابعة التصنيف (التواصل الطبي)';
  static const String ipaTranscription = '[nachˈˈɔʁdnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2877_nachordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung nachordnen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التصنيف في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
