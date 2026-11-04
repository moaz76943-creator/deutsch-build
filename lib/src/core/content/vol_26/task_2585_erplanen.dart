// Sovereign Polyglot Core - Task 2585 (Clinical Diagnostics)
class Task2585Engine {
  static const int taskId = 2585;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'erplanen';
  static const String praeteritum = 'erplante';
  static const String perfekt = 'hat erplant';
  static const String arabicTranslation = 'إنجاز / تحقيق التخطيط (التواصل الطبي)';
  static const String ipaTranscription = '[erˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2585_erplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung erplanen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التخطيط في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
